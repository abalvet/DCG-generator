#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from __future__ import annotations
import argparse
import json
import os
import random
import re
import sys
from collections import Counter
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterator, List

try:
    from pyswip import Prolog as _PySWIP
    PYSWIP_OK = True
except ImportError:
    PYSWIP_OK = False

UPOS_MAP = {'NPr': 'PROPN', 'NC': 'NOUN', 'Det': 'DET', 'V': 'VERB', 'Prép': 'ADP'}
VERB_FEATS = 'Mood=Ind|Tense=Pres|VerbForm=Fin'
LEX_RE = re.compile(r"^lex\(([^,]+),\s*'([^']+)',\s*([^,]+),\s*([^,]+),\s*([^\)]+)\)\.")


def _lemma_to_str(raw: str) -> str:
    raw = raw.strip()
    return raw[1:-1] if raw.startswith("'") and raw.endswith("'") else raw


def build_maps(lexicon_path: str):
    feats, lemmes = {}, {}
    with open(lexicon_path, encoding='utf-8') as fh:
        for line in fh:
            m = LEX_RE.match(line.strip())
            if not m:
                continue
            cat, form, g, n, lemma = m.groups()
            lemma = _lemma_to_str(lemma)
            lemmes[form] = lemma
            if cat == 'npr':
                fg = 'Fem' if g.strip() == 'f' else 'Masc' if g.strip() == 'm' else None
                fn = 'Sing' if n.strip() == 'sg' else 'Plur' if n.strip() == 'pl' else None
                parts = [p for p in [f'Gender={fg}' if fg else None, f'Number={fn}' if fn else None] if p]
                feats[form] = '|'.join(parts) if parts else '_'
            elif cat == 'nc':
                fg = 'Fem' if g.strip() == 'f' else 'Masc' if g.strip() == 'm' else None
                fn = 'Sing' if n.strip() == 'sg' else 'Plur' if n.strip() == 'pl' else None
                feats[form] = '|'.join([p for p in [f'Gender={fg}' if fg else None, f'Number={fn}' if fn else None] if p]) or '_'
            elif cat == 'det':
                fg = 'Fem' if g.strip() == 'f' else 'Masc' if g.strip() == 'm' else None
                fn = 'Sing' if n.strip() == 'sg' else 'Plur' if n.strip() == 'pl' else None
                defs = {'le': 'Def', 'un': 'Ind', 'ce': 'Dem', 'son': 'Prs'}
                pron = {'le': 'Art', 'un': 'Art', 'ce': 'Dem', 'son': 'Prs'}
                base = lemma
                parts = []
                if base in defs and base in ('le', 'un'):
                    parts.append(f'Definite={defs[base]}')
                if fg:
                    parts.append(f'Gender={fg}')
                if fn:
                    parts.append(f'Number={fn}')
                if base in pron:
                    parts.append(f'PronType={pron[base]}')
                feats[form] = '|'.join(parts) if parts else '_'
            elif cat.startswith('v_'):
                fn = 'Sing' if n.strip() == 'sg' else 'Plur' if n.strip() == 'pl' else None
                parts = ['Mood=Ind', 'Person=3', 'Tense=Pres', 'VerbForm=Fin']
                if fn:
                    parts.insert(2, f'Number={fn}')
                feats[form] = '|'.join(parts)
            else:
                feats.setdefault(form, '_')
    return feats, lemmes


def _parse_tree(s: str, i: int = 0):
    while i < len(s) and s[i].isspace():
        i += 1
    if s[i] != '[':
        raise ValueError(f'Expected [ at {i}')
    i += 1
    while i < len(s) and s[i].isspace():
        i += 1
    j = i
    while j < len(s) and not s[j].isspace() and s[j] != ']':
        j += 1
    cat = s[i:j]
    node = {'cat': cat, 'children': []}
    i = j
    while True:
        while i < len(s) and s[i].isspace():
            i += 1
        if i >= len(s):
            raise ValueError('Unexpected EOF')
        if s[i] == ']':
            return node, i + 1
        if s[i] == '[':
            child, i = _parse_tree(s, i)
            node['children'].append(child)
        else:
            j = i
            while j < len(s) and s[j] != ']':
                j += 1
            node['word'] = s[i:j].strip()
            i = j


def _collect(node, tokens):
    if 'word' in node:
        node['tok_id'] = len(tokens) + 1
        tokens.append({'tok_id': node['tok_id'], 'word': node['word'], 'cat': node['cat']})
    for c in node.get('children', []):
        _collect(c, tokens)


def _head_id(node):
    if 'tok_id' in node:
        return node['tok_id']
    for c in node.get('children', []):
        hid = _head_id(c)
        if hid is not None:
            return hid
    return None


def _deps(node, tokens):
    cat = node['cat']
    if cat == 'P':
        sn, sv = node['children']
        rid = _head_id(sv)
        sid = _head_id(sn)
        tokens[rid - 1]['head'], tokens[rid - 1]['deprel'] = 0, 'root'
        tokens[sid - 1]['head'], tokens[sid - 1]['deprel'] = rid, 'nsubj'
        _deps(sn, tokens)
        _deps(sv, tokens)
    elif cat == 'SN':
        nc_id = next((_head_id(c) for c in node['children'] if c['cat'] in ('NC', 'NPr')), None)
        for c in node['children']:
            if c['cat'] == 'Det':
                tokens[c['tok_id'] - 1]['head'] = nc_id
                tokens[c['tok_id'] - 1]['deprel'] = 'det'
    elif cat == 'SV':
        rid = _head_id(node)
        seen_obj = False
        for c in node['children']:
            if c['cat'] == 'SN':
                oid = _head_id(c)
                tokens[oid - 1]['head'], tokens[oid - 1]['deprel'] = rid, 'obj'
                _deps(c, tokens)
                seen_obj = True
            elif c['cat'] == 'SP':
                oid = _head_id(c)
                rel = 'iobj' if not seen_obj else 'obl:arg'
                tokens[oid - 1]['head'], tokens[oid - 1]['deprel'] = rid, rel
                _deps(c, tokens)
    elif cat == 'SP':
        sn = next(c for c in node['children'] if c['cat'] == 'SN')
        pr = next(c for c in node['children'] if c['cat'] == 'Prép')
        sn_h = _head_id(sn)
        tokens[pr['tok_id'] - 1]['head'] = sn_h
        tokens[pr['tok_id'] - 1]['deprel'] = 'case'
        _deps(sn, tokens)


def tree_to_conllu(tree_str: str, sent_id: str, feats_map: dict, lemmes: dict, meta: dict | None = None) -> str:
    tree, _ = _parse_tree(tree_str)
    tokens = []
    _collect(tree, tokens)
    _deps(tree, tokens)
    text = ' '.join(t['word'] for t in tokens)
    lines = [f'# sent_id = {sent_id}', f'# text = {text}']
    if meta:
        for k, v in meta.items():
            lines.append(f'# {k} = {v}')
    for t in tokens:
        form = t['word']
        cat = t['cat']
        upos = UPOS_MAP.get(cat, 'X')
        feats = feats_map.get(form, VERB_FEATS if upos == 'VERB' else '_')
        lemma = lemmes.get(form, form)
        lines.append('\t'.join([
            str(t['tok_id']), form, lemma, upos, '_', feats,
            str(t.get('head', '_')), t.get('deprel', '_'), '_', '_'
        ]))
    return '\n'.join(lines)


STRUCTS = ['v0', 'v1_sn', 'v2_sp', 'v3_sn_sp', 'v2_pp']


@dataclass
class Phrase:
    surface: str
    tree: str
    struct: str
    sent_id: str = ''
    conllu: str = ''

    def to_dict(self):
        return {'sent_id': self.sent_id, 'surface': self.surface, 'tree': self.tree, 'struct': self.struct, 'conllu': self.conllu}


class DCGGenerator:
    def __init__(self, grammar_file: str = 'grammaire_v5.pl', lexicon_file: str = 'lexique_v5.pl', seed: int | None = 42):
        if not PYSWIP_OK:
            raise ImportError('Installer pyswip : pip install pyswip')
        gpath = Path(grammar_file).resolve()
        lpath = Path(lexicon_file).resolve()
        os.chdir(gpath.parent)
        self._pl = _PySWIP()
        self._pl.consult(str(gpath))
        self._rng = random.Random(seed)
        self._feats, self._lemmes = build_maps(str(lpath))

    def stream(self, struct: str | None = None, limit: int = 10_000) -> Iterator[dict]:
        q = f"gen_phrase(S, T, {struct})" if struct else 'gen_phrase(S, T, St)'
        for r in self._pl.query(q, maxresult=limit):
            yield {'surface': str(r['S']), 'tree': str(r['T']), 'struct': struct or str(r['St'])}

    def sample(self, n: int = 20, structs: list[str] = STRUCTS, max_len: int = 9, prefix: str = 'codex') -> List[Phrase]:
        ts = datetime.now().strftime('%Y-%m-%d')
        meta = {'generatedBy': 'CODEX-DCG-v5', 'creationDate': ts, 'status': 'toCheck'}
        entries: List[Phrase] = []
        for struct in structs:
            collected = []
            for raw in self.stream(struct=struct, limit=n * 200):
                if len(raw['surface'].split()) > max_len:
                    continue
                collected.append(raw)
                if len(collected) >= n:
                    break
            entries.extend(Phrase(**r) for r in collected)
        self._rng.shuffle(entries)
        for i, e in enumerate(entries, 1):
            e.sent_id = f'{prefix}_{i:04d}'
            e.conllu = tree_to_conllu(e.tree, e.sent_id, self._feats, self._lemmes, meta)
        return entries

    def save_conllu(self, path: str, entries: List[Phrase]) -> None:
        Path(path).write_text('\n\n'.join(e.conllu for e in entries) + '\n', encoding='utf-8')

    def save_json(self, path: str, entries: List[Phrase]) -> None:
        data = {'generator': 'CODEX-DCG-v5', 'date': datetime.now().isoformat(timespec='seconds'), 'count': len(entries), 'phrases': [e.to_dict() for e in entries]}
        Path(path).write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

    def stats(self, entries: List[Phrase]) -> None:
        c = Counter(e.struct for e in entries)
        lg = [len(e.surface.split()) for e in entries]
        print(f'Total : {len(entries)}')
        for s in STRUCTS:
            if s in c:
                print(f'{s:<12}: {c[s]}')
        if lg:
            print(f'Longueur : moy={sum(lg)/len(lg):.1f} min={min(lg)} max={max(lg)}')


def main():
    ap = argparse.ArgumentParser(description='Générateur DCG CODEX v5')
    ap.add_argument('grammar', nargs='?', default='grammaire_v5.pl')
    ap.add_argument('--lexicon', default='lexique_v5.pl')
    ap.add_argument('-n', type=int, default=20)
    ap.add_argument('--max-len', type=int, default=9)
    ap.add_argument('--structs', nargs='+', choices=STRUCTS, default=STRUCTS)
    ap.add_argument('--seed', type=int, default=42)
    ap.add_argument('--out-conllu', default='output_v5.conllu')
    ap.add_argument('--out-json', default='output_v5.json')
    ap.add_argument('--prefix', default='codex')
    args = ap.parse_args()

    gen = DCGGenerator(args.grammar, lexicon_file=args.lexicon, seed=args.seed)
    entries = gen.sample(n=args.n, structs=args.structs, max_len=args.max_len, prefix=args.prefix)
    gen.stats(entries)
    gen.save_conllu(args.out_conllu, entries)
    gen.save_json(args.out_json, entries)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        main()
