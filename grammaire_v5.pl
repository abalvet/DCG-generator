:- encoding(utf8).
:- consult('lexique_v5.pl').
%TODO: fix "SN pense de SN"
% ============================================================
% grammaire_v5.pl -- DCG CODEX avec sélection sémantique légère
% ============================================================

% Hiérarchie sémantique légère.
isa(humain, humain).
isa(animé, animé).
isa(inanimé, inanimé).
isa(entité, entité).
isa(lieu, lieu).
isa(objet_concret, objet_concret).
isa(obj_info, obj_info).
isa(vêtement, vêtement).
isa(instrument, instrument).
isa(contenant, contenant).
isa(contenu, contenu).

isa(humain, animé).
isa(animé, entité).
isa(inanimé, entité).
isa(lieu, entité).
isa(objet_concret, inanimé).
isa(obj_info, objet_concret).
isa(vêtement, objet_concret).
isa(instrument, objet_concret).
isa(contenant, objet_concret).
isa(contenu, inanimé).

compat(C, C).
compat(Reelle, Requise) :-
    isa(Reelle, Parent),
    Reelle \= Parent,
    compat(Parent, Requise).

has_class(_, none) :- !.
has_class(Lemme, ClasseReq) :-
    sem(Lemme, ClasseReelle),
    compat(ClasseReelle, ClasseReq), !.

% ─────────────────────────────────────────────────────────────
% Contrôles minimaux anti-erreurs silencieuses
% ─────────────────────────────────────────────────────────────

lemme_de(Forme, Cat, Lemme) :- lex(Cat, Forme, _, _, Lemme).

check_lexique :-
    forall(lex(npr, _, _, _, L), sem(L, _)),
    forall(lex(nc,  _, _, _, L), sem(L, _)),
    forall(lex(v_intrans, _, _, _, L), sel(L, _, none, none)),
    forall(lex(v_trans_d, _, _, _, L), sel(L, _, _, none)),
    forall(lex(v_trans_i, _, _, _, L), (sel_prep(L, _, _, _) ; sel_pp(L, _, _, _, _, _))),
    forall(lex(v_ditrans, _, _, _, L), sel(L, _, _, _)).

% ─────────────────────────────────────────────────────────────
% Point d'entrée
% ─────────────────────────────────────────────────────────────

gen_phrase(Surface, Tree, Struct) :-
    phrase(p(Surface, Tree, Struct, []), _).

phrase_type(Struct, Surface, Tree, Length) :-
    gen_phrase(Surface, Tree, Struct),
    atomic_list_concat(Toks, ' ', Surface),
    length(Toks, Length).

% ─────────────────────────────────────────────────────────────
% Phrase
% ─────────────────────────────────────────────────────────────

p(Surface, Tree, Struct, Used0) -->
    sn(SN_S, SN_T, _G, Nb, SubjL, Used0, Used1),
    sv(SV_S, SV_T, Struct, SubjL, Nb, Used1, _Used2),
    { atomic_list_concat([SN_S, SV_S], ' ', Surface),
      format(atom(Tree), '[P ~w ~w]', [SN_T, SV_T]) }.

% ─────────────────────────────────────────────────────────────
% SN
% ─────────────────────────────────────────────────────────────

sn(Surf, Tree, G, Nb, Lemme, UsedIn, UsedOut) -->
    [Surf],
    { lex(npr, Surf, G, Nb, Lemme),
      \+ member(Lemme, UsedIn),
      UsedOut = [Lemme|UsedIn],
      format(atom(Tree), '[SN [NPr ~w]]', [Surf]) }.

sn(Surf, Tree, G, Nb, Lemme, UsedIn, UsedOut) -->
    [DS], [NS],
    { lex(det, DS, G, Nb, _),
      lex(nc,  NS, G, Nb, Lemme),
      \+ member(Lemme, UsedIn),
      UsedOut = [Lemme|UsedIn],
      format(atom(DT), '[Det ~w]', [DS]),
      format(atom(NT), '[NC ~w]', [NS]),
      atomic_list_concat([DS, NS], ' ', Surf),
      format(atom(Tree), '[SN ~w ~w]', [DT, NT]) }.

% ─────────────────────────────────────────────────────────────
% SP argumental : la préposition est imposée par la valence
% ─────────────────────────────────────────────────────────────

sp(PrepCat, Surf, Tree, Lemme, UsedIn, UsedOut) -->
    [PrepSurf],
    { lex(PrepCat, PrepSurf, _, _, _),
      format(atom(PT), '[Prép ~w]', [PrepSurf]) },
    sn(SN_S, SN_T, _, _, Lemme, UsedIn, UsedOut),
    { atomic_list_concat([PrepSurf, SN_S], ' ', Surf),
      format(atom(Tree), '[SP ~w ~w]', [PT, SN_T]) }.

% ─────────────────────────────────────────────────────────────
% SV
% ─────────────────────────────────────────────────────────────

sv(Surf, Tree, v0, SubjL, Nb, Used, Used) -->
    [VS],
    { lex(v_intrans, VS, _, Nb, VL),
      sel(VL, SujCls, none, none),
      has_class(SubjL, SujCls),
      Surf = VS,
      format(atom(Tree), '[SV [V ~w]]', [VS]) }.

sv(Surf, Tree, v1_sn, SubjL, Nb, UsedIn, UsedOut) -->
    [VS],
    { lex(v_trans_d, VS, _, Nb, VL) },
    sn(SN_S, SN_T, _, _, ObjL, UsedIn, UsedOut),
    { sel(VL, SujCls, ObjCls, none),
      has_class(SubjL, SujCls),
      has_class(ObjL, ObjCls),
      atomic_list_concat([VS, SN_S], ' ', Surf),
      format(atom(VT), '[V ~w]', [VS]),
      format(atom(Tree), '[SV ~w ~w]', [VT, SN_T]) }.

sv(Surf, Tree, v2_sp, SubjL, Nb, UsedIn, UsedOut) -->
    [VS],
    { lex(v_trans_i, VS, _, Nb, VL),
      sel_prep(VL, PrepCat, SujCls, OICls) },
    sp(PrepCat, SP_S, SP_T, OblL, UsedIn, UsedOut),
    { has_class(SubjL, SujCls),
      has_class(OblL, OICls),
      atomic_list_concat([VS, SP_S], ' ', Surf),
      format(atom(VT), '[V ~w]', [VS]),
      format(atom(Tree), '[SV ~w ~w]', [VT, SP_T]) }.

sv(Surf, Tree, v3_sn_sp, SubjL, Nb, UsedIn, UsedOut) -->
    [VS],
    { lex(v_ditrans, VS, _, Nb, VL) },
    sn(OD_S, OD_T, _, _, ObjL, UsedIn, Used1),
    sp(prep_a, SP_S, SP_T, OblL, Used1, UsedOut),
    { sel(VL, SujCls, ObjCls, OICls),
      has_class(SubjL, SujCls),
      has_class(ObjL, ObjCls),
      has_class(OblL, OICls),
      atomic_list_concat([VS, OD_S, SP_S], ' ', Surf),
      format(atom(VT), '[V ~w]', [VS]),
      format(atom(Tree), '[SV ~w ~w ~w]', [VT, OD_T, SP_T]) }.

sv(Surf, Tree, v2_pp, SubjL, Nb, UsedIn, UsedOut) -->
    [VS],
    { lex(v_trans_i, VS, _, Nb, VL),
      sel_pp(VL, Prep1, C1, Prep2, C2, SujCls) },
    sp(Prep1, SP1_S, SP1_T, L1, UsedIn, Used1),
    sp(Prep2, SP2_S, SP2_T, L2, Used1, UsedOut),
    { has_class(SubjL, SujCls),
      has_class(L1, C1),
      has_class(L2, C2),
      atomic_list_concat([VS, SP1_S, SP2_S], ' ', Surf),
      format(atom(VT), '[V ~w]', [VS]),
      format(atom(Tree), '[SV ~w ~w ~w]', [VT, SP1_T, SP2_T]) }.
