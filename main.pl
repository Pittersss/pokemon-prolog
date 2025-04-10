:- use_module(library(pce)).
:- use_module('modules/logic/pokemon').
:- use_module('modules/logic/battle_system').

% Inicialização manual para garantir que XPCE está ativo
run_game :-
    carregar_tudo,
    pokemons_disponiveis(Selecionados), 
    writeln(Selecionados),
    maplist(gera_pokemon_battle_inicial, Selecionados),
    maplist(gera_pokemon_battle_inicial, ['Dewgong', 'Cloyster', 'Slowbro', 'Pidgeot', 'Lapras']),
    battle(Selecionados, ['Dewgong', 'Cloyster', 'Slowbro', 'Pidgeot', 'Lapras']).

