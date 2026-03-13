:- encoding(utf8).
%TODO: fix "SN pense de SN"
% ============================================================
% lexique_v5.pl -- Lexique CODEX (prototype opérationnel)
% ============================================================
% Principes :
% - lex/5 : catégorie, forme, genre/personne, nombre, lemme
% - sem/2 : classes sémantiques portées par les lemmes nominaux
% - sel/4 : V0, V1 et V3 SN+SP classiques
% - sel_prep/4 : V + un SP argumental (préposition + classe)
% - sel_pp/6 : V + deux SP argumentaux ordonnés
% - check_lexique/0 dans la grammaire vérifie les cas principaux
% ============================================================

:- discontiguous lex/5.
:- discontiguous sem/2.
:- discontiguous sel/4.
:- discontiguous sel_prep/4.
:- discontiguous sel_pp/6.

% ─────────────────────────────────────────────────────────────
% NOMS PROPRES
% ─────────────────────────────────────────────────────────────

lex(npr, 'Léa',      f, sg, léa).
lex(npr, 'Harry',    m, sg, harry).
lex(npr, 'Ron',      m, sg, ron).
lex(npr, 'Hermione', f, sg, hermione).
lex(npr, 'Neville',  m, sg, neville).
lex(npr, 'Luna',     f, sg, luna).
lex(npr, 'Poudlard', _, sg, poudlard).

sem(léa, humain).
sem(harry, humain).
sem(ron, humain).
sem(hermione, humain).
sem(neville, humain).
sem(luna, humain).
sem(poudlard, lieu).

% ─────────────────────────────────────────────────────────────
% DÉTERMINANTS
% ─────────────────────────────────────────────────────────────

lex(det, 'le',    m, sg, le).
lex(det, 'la',    f, sg, le).
lex(det, 'les',   _, pl, le).
lex(det, 'un',    m, sg, un).
lex(det, 'une',   f, sg, un).
lex(det, 'des',   _, pl, un).
lex(det, 'ce',    m, sg, ce).
lex(det, 'cette', f, sg, ce).
lex(det, 'ces',   _, pl, ce).
lex(det, 'ma',   f, sg, son).
lex(det, 'mon',   m, sg, son).
lex(det, 'mes',   m, pl, son).
lex(det, 'ta',   f, sg, son).
lex(det, 'tes',   _, pl, son).
lex(det, 'notre',   _, sg, son).
lex(det, 'nos',   _, pl, son).
lex(det, 'votre',   _, sg, son).
lex(det, 'vos',   _, pl, son).
lex(det, 'leur',   _, pl, son).
lex(det, 'son',   m, sg, son).
lex(det, 'sa',    f, sg, son).
lex(det, 'ses',   _, pl, son).

% ─────────────────────────────────────────────────────────────
% NOMS COMMUNS HUMAINS
% ─────────────────────────────────────────────────────────────

lex(nc, 'sorcier',      m, sg, sorcier).
lex(nc, 'sorciers',     m, pl, sorcier).
lex(nc, 'sorcière',     f, sg, sorcier).
lex(nc, 'sorcières',    f, pl, sorcier).
lex(nc, 'magicien',     m, sg, magicien).
lex(nc, 'magiciens',    m, pl, magicien).
lex(nc, 'magicienne',   f, sg, magicien).
lex(nc, 'magiciennes',  f, pl, magicien).
lex(nc, 'nain',         m, sg, nain).
lex(nc, 'nains',        m, pl, nain).
lex(nc, 'naine',        f, sg, nain).
lex(nc, 'naines',       f, pl, nain).

sem(sorcier, humain).
sem(magicien, humain).
sem(nain, humain).

% ─────────────────────────────────────────────────────────────
% NOMS COMMUNS ANIMÉS NON HUMAINS
% ─────────────────────────────────────────────────────────────

lex(nc, 'chat',         m, sg, chat).
lex(nc, 'chats',        m, pl, chat).
lex(nc, 'chatte',       f, sg, chat).
lex(nc, 'chattes',      f, pl, chat).
lex(nc, 'chien',        m, sg, chien).
lex(nc, 'chiens',       m, pl, chien).
lex(nc, 'chienne',      f, sg, chien).
lex(nc, 'chiennes',     f, pl, chien).
lex(nc, 'lion',         m, sg, lion).
lex(nc, 'lions',        m, pl, lion).
lex(nc, 'lionne',       f, sg, lion).
lex(nc, 'lionnes',      f, pl, lion).
lex(nc, 'hibou',        m, sg, hibou).
lex(nc, 'hiboux',       m, pl, hibou).
lex(nc, 'crapaud',      m, sg, crapaud).
lex(nc, 'crapauds',     m, pl, crapaud).
lex(nc, 'dragon',       m, sg, dragon).
lex(nc, 'dragons',      m, pl, dragon).
lex(nc, 'basilic',      m, sg, basilic).
lex(nc, 'basilics',     m, pl, basilic).
lex(nc, 'démon',        m, sg, démon).
lex(nc, 'démons',       m, pl, démon).
lex(nc, 'serpent',      m, sg, serpent).
lex(nc, 'serpents',     m, pl, serpent).
lex(nc, 'chouette',     f, sg, chouette).
lex(nc, 'chouettes',    f, pl, chouette).
lex(nc, 'souris',       f, sg, souris).
lex(nc, 'souris',       f, pl, souris).
lex(nc, 'grenouille',   f, sg, grenouille).
lex(nc, 'grenouilles',  f, pl, grenouille).
lex(nc, 'licorne',      f, sg, licorne).
lex(nc, 'licornes',     f, pl, licorne).
lex(nc, 'harpie',       f, sg, harpie).
lex(nc, 'harpies',      f, pl, harpie).

sem(chat, animé).
sem(chien, animé).
sem(lion, animé).
sem(hibou, animé).
sem(crapaud, animé).
sem(dragon, animé).
sem(basilic, animé).
sem(démon, animé).
sem(serpent, animé).
sem(chouette, animé).
sem(souris, animé).
sem(grenouille, animé).
sem(licorne, animé).
sem(harpie, animé).

% ─────────────────────────────────────────────────────────────
% NOMS COMMUNS INANIMÉS / CLASSES PLUS FINES
% ─────────────────────────────────────────────────────────────

lex(nc, 'livre',        m, sg, livre).
lex(nc, 'livres',       m, pl, livre).
lex(nc, 'balai',        m, sg, balai).
lex(nc, 'balais',       m, pl, balai).
lex(nc, 'chapeau',      m, sg, chapeau).
lex(nc, 'chapeaux',     m, pl, chapeau).
lex(nc, 'parchemin',    m, sg, parchemin).
lex(nc, 'parchemins',   m, pl, parchemin).
lex(nc, 'miroir',       m, sg, miroir).
lex(nc, 'miroirs',      m, pl, miroir).
lex(nc, 'chaudron',     m, sg, chaudron).
lex(nc, 'chaudrons',    m, pl, chaudron).
lex(nc, 'grimoire',     m, sg, grimoire).
lex(nc, 'grimoires',    m, pl, grimoire).
lex(nc, 'ballon',       m, sg, ballon).
lex(nc, 'ballons',      m, pl, ballon).

lex(nc, 'baguette',     f, sg, baguette).
lex(nc, 'baguettes',    f, pl, baguette).
lex(nc, 'potion',       f, sg, potion).
lex(nc, 'potions',      f, pl, potion).
lex(nc, 'lettre',       f, sg, lettre).
lex(nc, 'lettres',      f, pl, lettre).
lex(nc, 'plume',        f, sg, plume).
lex(nc, 'plumes',       f, pl, plume).
lex(nc, 'cape',         f, sg, cape).
lex(nc, 'capes',        f, pl, cape).
lex(nc, 'carte',        f, sg, carte).
lex(nc, 'cartes',       f, pl, carte).

sem(livre, obj_info).
sem(parchemin, obj_info).
sem(grimoire, obj_info).
sem(lettre, obj_info).
sem(carte, obj_info).

sem(balai, instrument).
sem(baguette, instrument).
sem(plume, instrument).

sem(chapeau, vêtement).
sem(cape, vêtement).

sem(chaudron, contenant).
sem(potion, contenu).
sem(miroir, objet_concret).
sem(ballon, objet_concret).

% ─────────────────────────────────────────────────────────────
% VERBES
% ─────────────────────────────────────────────────────────────

% V0
lex(v_intrans, 'dort',       3, sg, dormir).
lex(v_intrans, 'dorment',    3, pl, dormir).
lex(v_intrans, 'court',      3, sg, courir).
lex(v_intrans, 'courent',    3, pl, courir).
lex(v_intrans, 'rêve',       3, sg, rêver).
lex(v_intrans, 'rêvent',     3, pl, rêver).
lex(v_intrans, 'rit',        3, sg, rire).
lex(v_intrans, 'rient',      3, pl, rire).
lex(v_intrans, 'tremble',    3, sg, trembler).
lex(v_intrans, 'tremblent',  3, pl, trembler).
lex(v_intrans, 'sourit',     3, sg, sourire).
lex(v_intrans, 'sourient',   3, pl, sourire).
lex(v_intrans, 'voyage',     3, sg, voyager).
lex(v_intrans, 'voyagent',   3, pl, voyager).

sel(dormir,    animé,  none, none).
sel(courir,    animé,  none, none).
sel(rêver,     animé,  none, none).
sel(rire,      humain, none, none).
sel(trembler,  animé,  none, none).
sel(sourire,   humain, none, none).
sel(voyager,   humain, none, none).

% V1
lex(v_trans_d, 'lit',        3, sg, lire).
lex(v_trans_d, 'lisent',     3, pl, lire).
lex(v_trans_d, 'trouve',     3, sg, trouver).
lex(v_trans_d, 'trouvent',   3, pl, trouver).
lex(v_trans_d, 'cherche',    3, sg, chercher).
lex(v_trans_d, 'cherchent',  3, pl, chercher).
lex(v_trans_d, 'lance',      3, sg, lancer).
lex(v_trans_d, 'lancent',    3, pl, lancer).
lex(v_trans_d, 'porte',      3, sg, porter).
lex(v_trans_d, 'portent',    3, pl, porter).
lex(v_trans_d, 'prend',      3, sg, prendre).
lex(v_trans_d, 'prennent',   3, pl, prendre).
lex(v_trans_d, 'nettoie',    3, sg, nettoyer).
lex(v_trans_d, 'nettoient',  3, pl, nettoyer).
lex(v_trans_d, 'aime',       3, sg, aimer).
lex(v_trans_d, 'aiment',     3, pl, aimer).
lex(v_trans_d, 'voit',       3, sg, voir).
lex(v_trans_d, 'voient',     3, pl, voir).

sel(lire,      humain, obj_info,      none).
sel(trouver,   animé,  entité,        none).
sel(chercher,  animé,  entité,        none).
sel(lancer,    animé,  objet_concret, none).
sel(porter,    animé,  objet_concret, none).
sel(prendre,   animé,  objet_concret, none).
sel(nettoyer,  humain, objet_concret, none).
sel(aimer,     animé,  entité,        none).
sel(voir,      animé,  entité,        none).

% V2 (un seul SP argumental)
lex(v_trans_i, 'parle',         3, sg, parler).
lex(v_trans_i, 'parlent',       3, pl, parler).
lex(v_trans_i, 'répond',        3, sg, répondre).
lex(v_trans_i, 'répondent',     3, pl, répondre).
lex(v_trans_i, 'résiste',       3, sg, résister).
lex(v_trans_i, 'résistent',     3, pl, résister).
lex(v_trans_i, 'appartient',    3, sg, appartenir).
lex(v_trans_i, 'appartiennent', 3, pl, appartenir).
lex(v_trans_i, 'obéit',         3, sg, obéir).
lex(v_trans_i, 'obéissent',     3, pl, obéir).
lex(v_trans_i, 'ressemble',     3, sg, ressembler).
lex(v_trans_i, 'ressemblent',   3, pl, ressembler).
lex(v_trans_i, 'pense',         3, sg, penser).
lex(v_trans_i, 'pensent',       3, pl, penser).

sel_prep(parler,      prep_a,  humain, humain).
sel_prep(parler,      prep_de, humain, entité).
sel_prep(répondre,    prep_a,  humain, humain).
sel_prep(résister,    prep_a,  animé,  animé).
sel_prep(appartenir,  prep_a,  entité, humain).
sel_prep(obéir,       prep_a,  animé,  animé).
sel_prep(ressembler,  prep_a,  entité, entité).
sel_prep(penser,      prep_a,  humain, entité).
sel_prep(penser,      prep_de, humain, entité).

% V2 à deux SP argumentaux, ordonnés
sel_pp(parler, prep_a,  humain, prep_de, entité, humain).
sel_pp(parler, prep_de, entité, prep_a,  humain, humain).

% V3 (SN + SP)
lex(v_ditrans, 'donne',       3, sg, donner).
lex(v_ditrans, 'donnent',     3, pl, donner).
lex(v_ditrans, 'offre',       3, sg, offrir).
lex(v_ditrans, 'offrent',     3, pl, offrir).
lex(v_ditrans, 'montre',      3, sg, montrer).
lex(v_ditrans, 'montrent',    3, pl, montrer).
lex(v_ditrans, 'envoie',      3, sg, envoyer).
lex(v_ditrans, 'envoient',    3, pl, envoyer).
lex(v_ditrans, 'apporte',     3, sg, apporter).
lex(v_ditrans, 'apportent',   3, pl, apporter).
lex(v_ditrans, 'explique',    3, sg, expliquer).
lex(v_ditrans, 'expliquent',  3, pl, expliquer).
lex(v_ditrans, 'prête',       3, sg, prêter).
lex(v_ditrans, 'prêtent',     3, pl, prêter).

sel(donner,     humain, objet_concret, humain).
sel(offrir,     humain, objet_concret, humain).
sel(montrer,    humain, entité,        humain).
sel(envoyer,    humain, objet_concret, humain).
sel(apporter,   humain, objet_concret, humain).
sel(expliquer,  humain, obj_info,      humain).
sel(prêter,     humain, objet_concret, humain).

% ─────────────────────────────────────────────────────────────
% PRÉPOSITIONS
% ─────────────────────────────────────────────────────────────

lex(prep_a,   'à',    _, _, à).
lex(prep_de,  'de',   _, _, de).
lex(prep_sur, 'sur',  _, _, sur).
lex(prep_par, 'par',  _, _, par).
