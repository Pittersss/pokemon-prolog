:- use_module('modules/logic/pokemon').
:- use_module('modules/logic/battle_system').
:- use_module('modules/logic/historico').

% Inicialização manual para garantir que XPCE está ativo
run_game :-
    carregar_tudo,
    iniciar_placar,
    pokemons_disponiveis(Selecionados),
    maplist(gera_pokemon_battle_inicial, Selecionados),
    maplist(gera_pokemon_battle_inicial, ['Dewgong', 'Cloyster', 'Slowbro', 'Pidgeot', 'Lapras']),
    battle(Selecionados, ['Dewgong', 'Cloyster', 'Slowbro', 'Pidgeot', 'Lapras']).