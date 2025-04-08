:- module(main, [battle_flux/1]).
:- use_module(library(pce)).
:- use_module('modules/visual/menu').
:- use_module('modules/logic/pokemon').

:- initialization(init).

init :-
    % Salva referência para continuar o jogo após seleção
    nb_setval(selection_callback, main:handle_selected_pokemons),
    create_menu.

% Lógica da gameplay
handle_selected_pokemons(Selecionados) :-
    maplist(pokemon:criar_battle_pokemon, Selecionados, ListaBattle),
    battle_flux(ListaBattle).

battle_flux(ListaBattle) :-
    format("Iniciando batalha com pokémons: ~w~n", [ListaBattle]).











































% ATENÇÃO: ESSE MAIN É APENAS PARA PROPÓSITOS DE TESTE, OU SEJA, PODE DELETÁ-LO
main:-
    selecionados(Selected),
    writeln(Selected),
    write('AAAAAAAAAAAAAAAAAAAAAA'),
    writeln('===== Sistema de Batalha Pokémon ====='),
    carregar_tudo,
            
    % Mostra alguns dados carregados
    writeln('\n=== Pokémons Carregados =='),
    findall(Nome, pokemon(Nome, _, _, _, _, _, _, _, _, _, _, _, _), ListaPokemons),
    write('Pokémons: '), writeln(ListaPokemons),
    
    writeln('\n=== Ataques Carregados =='),
    findall(Nome, attack(Nome, _, _, _, _, _, _, _), ListaAtaques),
    write('Ataques: '), writeln(ListaAtaques),
    
    % Testa a criação de uma batalha
    writeln('\n=== Teste de Batalha =='),

    gera_pokemon_battle_inicial('Pikachu'),
    gera_pokemon_battle_inicial('Charizard'),
    gera_pokemon_battle_inicial('Dragonite'),

    % Fazendo testes     

    % Mostra o Pokémon em batalha
    writeln('\n=== Estado da Batalha =='),
    pokemon_battle('Charizard', HP, Atk1, Atk2, Atk3, Atk4, Condicao),
    write('Pokémon: '), writeln(Pokemon),
    write('HP: '), writeln(HP),
    write('Ataque 1: '), writeln(Atk1),
    write('Condição: '), writeln(Condicao),
    writeln('\n=== Fim do Teste ==='),

    writeln('\n===Teste de Batalha==='),
    realiza_ataque('Pikachu','Charizard', 4),
    pokemon_battle('Charizard',Hp_Atual,_,_,_,_,_),
    writeln("Hp antigo é: "),
    writeln(HP),
    writeln("Hp atual é: "),
    writeln(Hp_Atual),
    realiza_ataque('Pikachu','Dragonite', 1),
    pokemon_battle('Dragonite',New_Hp_atual,_,_,_,_,_),
    writeln("Novo Hp é: "),
    writeln(New_Hp_atual).


