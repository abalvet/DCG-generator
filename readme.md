# DCG-based Sentence Generator / Générateur de phrases à base de DCG

This is a prototype of a formal grammar approach to sentence generation (in French for now).


**Author**: A. BALVET, Université de Lille, UMR STL 8163, projet CODEX, [LIIAN (Linguistique Informatique pour l'Inclusion et l'Accessibilité Numérique) master's program](https://formation.univ-lille.fr/fr/offre-de-formation/master-lmd-XB/master-sciences-du-langage-MG002189/linguistique-informatique-pour-l-inclusion-et-l-accessibilite-numerique-MX002192.html)

**Professional page**: https://pro.univ-lille.fr/antonio-balvet


---

# Overview
## EN

### Resource footprint and hardware requirements

This generator is computationally lightweight compared with LLM-based generation pipelines.
It relies on:
  - a symbolic grammar in Prolog
  - a lightweight Python orchestration layer
  - no neural inference
  - no large model weights to load in memory

In practice, the main cost is not the generation itself, but the size of the exported data files (especially full CoNLL-U and JSON outputs).
On a Linux workstation equipped with an Intel Core i5 and 12 GB RAM, the system can generate 100,000 sentences in under 60 seconds. At that scale, output size becomes the main practical constraint:
  - CoNLL-U export: 200+ MB
  - JSON export: 380+ MB

This means that the generator is suitable for modest hardware, including older laptops or desktop machines, and potentially low-power devices for small to medium batches. However, generating and storing very large datasets on smartphones or tablets is generally not the intended use case, mainly because of storage and file-size constraints rather than raw linguistic processing cost.

In short, this prototype is designed to demonstrate that highly controlled sentence generation can be fast, local, and resource-efficient, without requiring the infrastructure typically associated with LLMs.

# Aperçu
### FR

#### Consommation de ressources 

Ce générateur est très léger sur le plan computationnel en comparaison des pipelines de génération fondés sur des LLM.

Il repose sur :
  - une grammaire formelle en Prolog
  - une couche légère d’orchestration en Python
  - aucune inférence neuronale
  - aucun chargement de poids massifs en mémoire

En pratique, le principal coût ne vient pas de la génération elle-même, mais de la taille des fichiers exportés, en particulier lorsque l’on produit des sorties complètes en CoNLL-U et en JSON.

Sur une station Linux équipée d’un processeur Intel Core i5 et de 12 Go de RAM, le système peut générer 100 000 phrases en moins de 60 secondes. À cette échelle, la contrainte principale devient la taille des sorties :
  - export CoNLL-U : plus de 200 Mo
  - export JSON : plus de 380 Mo

Cela signifie que le générateur peut fonctionner sur du matériel modeste, y compris des ordinateurs anciens. Il peut aussi, en principe, être exécuté sur des dispositifs peu puissants pour de petits ou moyens lots. En revanche, la génération et surtout le stockage de très gros jeux de données sur smartphone ou tablette ne correspondent pas à l’usage visé, principalement à cause des volumes de sortie et des contraintes de stockage, et non à cause du coût linguistique de traitement lui-même.

En résumé, ce prototype montre qu’une génération de phrases fortement contrôlée, locale et économe en ressources est possible, sans l’infrastructure habituellement requise par les LLM.

## EN

This project implements a **controlled sentence generator for French** using a **formal grammar written in Prolog (DCG: Definite Clause Grammar)** and a **Python interface**.

The generator produces sentences that are:

* syntactically controlled
* semantically filtered
* morphologically consistent

Each generated sentence is associated with:

* a **constituency tree**
* a **dependency graph (CoNLL-U)**

The generator is designed for:

* linguistic pedagogy
* NLP dataset generation
* syntactic exercise creation
* evaluation of language models

---

## FR

Ce projet implémente un **générateur contrôlé de phrases françaises** basé sur :

* une **grammaire symbolique en Prolog (DCG: Definite Clause Grammar)**
* une **interface Python**

Le système produit des phrases :

* syntaxiquement contrôlées
* sémantiquement filtrées
* morphologiquement cohérentes

Chaque phrase générée est associée à :

* un **arbre de constituants**
* un **graphe de dépendances (CoNLL-U)**

Le générateur est conçu pour :

* la pédagogie de la syntaxe
* la génération de datasets NLP
* la création d’exercices linguistiques
* l’évaluation de modèles de langue

---

# Architecture

```
             +-------------------+
             |   Python Script   |
             | dcg_generator_v5  |
             +---------+---------+
                       |
                       |
                       v
            +--------------------+
            |    SWI-Prolog      |
            | DCG Grammar Engine |
            +---------+----------+
                      |
        +-------------+-------------+
        |                           |
        v                           v
+--------------+           +----------------+
|  Lexicon     |           |   Grammar      |
| lexique_v5   |           | grammaire_v5   |
+--------------+           +----------------+
```

---

# Repository Structure / Structure du projet 

```
project/
│
├── lexique_v5.pl
├── grammaire_v5.pl
├── dcg_generator_v5.py
│
└── README.md
```

| File                | Role                |
| ------------------- | ------------------- |
| lexique_v5.pl       | lexical database    |
| grammaire_v5.pl     | grammar rules       |
| dcg_generator_v5.py | generator interface |
| sample_v3.conllu    | example output      |

---

# What is a DCG?

## EN

A **Definite Clause Grammar (DCG)** is a way to describe formal grammars in Prolog.

Example rule:

```
sentence --> np, vp.
```

Meaning:

```
Sentence → NounPhrase + VerbPhrase
```
In other words: we need a Noun Phrase AND a Verb Phrase (in this order) to build a Sentence. 

Prolog can **generate or parse sentences** using the same grammar.

---

# Qu'est-ce qu'une DCG?
## FR

Une **DCG (Definite Clause Grammar)** est une façon d’écrire une grammaire formelle en Prolog.

Exemple :

```
phrase --> sn, sv.
```

Signifie :

```
Phrase → SN + SV
```
Autrement dit: une Phrase doit contenir exactement un SN ET un SV (dans cet ordre).

La même grammaire permet :

* de générer des phrases
* de les analyser

---

# Sentence Generation Pipeline 

```
Lexicon
   ↓
Grammar
   ↓
Sentence generation
   ↓
Constituency tree
   ↓
Dependency graph
   ↓
CoNLL-U export
```

---

# Example Generation

Sentence produced:

```
Léa lit son livre
```

Constituency tree:

```
phrase
 ├─ SN
 │   └─ Léa
 └─ SV
     ├─ lit
     └─ SN
         ├─ son
         └─ livre
```

---

# Example Dependency Graph (CoNLL-U)

```
1   Léa    Léa    PROPN   _   _   2   nsubj
2   lit    lire   VERB    _   _   0   root
3   son    son    DET     _   _   4   det
4   livre  livre  NOUN    _   _   2   obj
```

---

# Lexicon Structure

Each lexical entry:

```
lex(Form, Lemma, Category, Features, SemanticClass).
```

Example:

```
lex(lit, lire, v, [3,sing], none).
lex(livre, livre, nc, [masc,sing], obj_info).
```

---

# Semantic Classes

Minimal semantic hierarchy:

**EN**
```
entity
 ├─ human
 ├─ animate
 ├─ physical_object
 │   ├─ instrument
 │   ├─ clothing
 │   └─ container
 ├─ information_object
 └─ location
```

**FR**

```
entité
 ├─ humain
 ├─ animé
 ├─ objet_concret
 │   ├─ instrument
 │   ├─ vêtement
 │   └─ contenant
 ├─ obj_info
 └─ lieu
```

**Note:** *humans* should probably be considered as a subclass of *animate*.

Example:

| Word     | Class      |
| -------- | ---------- |
| livre    | obj_info   |
| chapeau  | vêtement   |
| baguette | instrument |

This allows to avoid blatant inconsistencies:

✔ Léa lit son livre
✘ Léa lit son chapeau

---

# Verb Argument Structure

Verb constraints are encoded using:

```
sel(VerbLemma, SubjectClass, ObjectClass, PrepObjectClass).
```

Example:

```
sel(lire, humain, obj_info, none).
```

---

# Prepositional Arguments

Single PP:

```
sel_prep(verbe, sujet, prep, objet).
```

Example:

```
penser à quelque chose
```

---

Double PP:

```
sel_pp(verbe, sujet, prep1, obj1, prep2, obj2).
```

Example:

```
parler à quelqu’un de quelque chose
parler de quelque chose à quelqu’un
```

---

# Installation

## Requirements

Python ≥ 3.9
SWI-Prolog ≥ 9

---

## Install SWI-Prolog

Linux

```
sudo apt install swi-prolog
```

Mac

```
brew install swi-prolog
```

Windows

Download:

[https://www.swi-prolog.org/download/stable](https://www.swi-prolog.org/download/stable)

---

## Install Python dependencies

**Note:** creating and activating a virtual environment is needed, unless you use this code in a notebook.

```
python -m venv dcg-generator
source dcg-generator/bin/activate
```
Once the virtual environment is created, install required libraries: 

```
(dcg-generator)$ pip install pyswip
(dcg-generator)$ pip install conllu
```

---

# Running the Generator

Basic usage:

```
(dcg-generator)$ python dcg_generator_v5.py
```

Generate 1000 sentences for a given structure:

```
(dcg-generator)$ python dcg_generator_v5.py -n 100000 --structs v3_sn_sp

```

Export CoNLL-U:

```
(dcg-generator)$ python dcg_generator_v5.py --conllu output.conllu
```


### CLI: options
| Option | Default | Description |
|---|---|---|
| `grammar` | `grammaire_v3.pl` | path to grammar file |
| `-n N` | 20 | number of sentences to generate |
| `--structs` | all | Filter one or more structures (`v0 v1_sn v2_sp v3_sn_sp`) |
| `--max-len N` | 7 | Max length in tokens |
| `--out-conllu` | `output.conllu` |  CoNLL-U output file |
| `--out-json` | `output.json` |  JSON output file: dependency graph + constituent tree |
| `--prefix` | `codex` | Sentence identifier prefix (`codex_0001`, etc.) |
| `--seed` | 42 | Random seed (for reproductibility) |

---

# Editing the Lexicon

Add a new noun:

```
lex(baguette, baguette, nc, [fem,sing], instrument).
```

Add verb constraints:

```
sel(utiliser, humain, instrument, none).
```

---

# Editing the Grammar

To add a new syntactic structure, first make sure you understand how the lexicon is declared, since this will constrain how rules can be written.
The grammar rules is just a Prolog-structured text file. 

**TODO**: explain the current formalism.

---

# Validation

Run inside Prolog:

```
check_lexique.
```

Detects:

* missing semantic classes
* inconsistent verb selection
* incomplete lexical entries

---

# Performance

On a consumer-grade linux PC: 

| Sentences | Time |
| --------- | ---- |
| 1k       | ~ 2s |
| 10k       | ~ 20s |
| 100k       | ~60s  |

Yes, it's **fast**!

**Beware**: generating 100k sentences yields a 200 Mb Conll-U file + a 338 Mb json file.

---

# Use Cases

* syntax teaching
* corpus generation
* NLP training datasets
* LLM evaluation

---

# Integration in CODEX

Pipeline:

```
Sentence generator
        ↓
Corpus
        ↓
Syntactic analysis
        ↓
Exercise generation
```

---

# Roadmap

## Known limitations

The present DCG-based sentence generator is not a full-fledged **text** generator. It is also not a full-fledged sentence generator, in the sense that the defined formalism is a compromise between linguistic precision, coverage and ease of use. To this date, no formal theory has ever yielded a fully-mature text or sentence generator. The current version tries to overcome most limitations and inconsistencies, nevertheless the produced sentences are not 100% perfect or semantically consistent. Example: "Léa pense de Ron" is accepted in the current grammar (fix soon to come).

A proper documentation for the formalism used is needed.

## Limitations connues

Ce générateur de phrases à partir de DCG n'est pas un générateur mature de **textes**. Ce n'est pas non plus un générateur 100% mature de phrases, dans le sens où le formalisme employé est essentiellement un compromis entre la finesse linguistique désirée, la couverture, et la facilité de prise en main. À noter: à ce jour, aucun formalisme n'a produit de système de génération de phrases ou de textes complètement mature. La version courante tente de dépasser les principales limitations et incohérences, toutefois, les phrases produites ne sont pas 100% parfaites ni sémantiquement cohérentes.  Exemple: "Léa pense de Ron" est acceptée par la grammaire  actuelle (correction à venir).

Une documentation du formalisme utilisé est prévue.

## Toward TRL-4

### Short term

* better semantic hierarchy
* lexical coverage extension
* automatic lexicon validation

---

### Medium term

Integration with lexical resources:

* Dicovalence
* TLFi XML
* French Lexical Network

---

### Long term

* hybrid symbolic + LLM validation
* multi-agent architecture
* adaptive pedagogical corpus generation

---

# Contributing

Contributions welcome:

* lexicon extensions, other languages than French
* grammar rules: more structures, more constraints
* semantic classes
* dataset generation tools
* output evaluation

---

# License

MIT License.
