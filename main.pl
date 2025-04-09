:- module(main, [handle_selected_pokemons/1, log_message/2]).
:- use_module(library(pce)).
:- use_module('modules/visual/menu').
:- use_module('modules/logic/pokemon').
:- use_module('modules/logic/battle_system', [battle/2]).
:- use_module('modules/logic/logger').

% Lógica de batalha centralizada
handle_selected_pokemons(Selecionados) :-
    carregar_tudo,
    gera_pokemons_battle(Selecionados, USU_TEAM),
    gera_pokemons_battle([Dewgong, Cloyster, Slowbro, Jynx, Lapras], ENEMY_TEAM),
    write(ENEMY_TEAM),
    battle(USU_TEAM, ENEMY_TEAM).

% Inicialização manual para garantir que XPCE está ativo
run_game :-
    % 🔧 Isso garante que a variável global existe ANTES da GUI abrir
    (   nb_current(selection_callback, _) -> true
    ;   nb_setval(selection_callback, handle_selected_pokemons)
    ),
    create_menu.


% Chamada segura após carregamento do XPCE
:- pce_autoload_all.
:- initialization(pce_dispatch(run_game)).
