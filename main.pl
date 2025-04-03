:- use_module(library(csv)).
:- dynamic pokemon/13, attack/8, pokemon_battle/7.

% pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Attack1, Attack2, Attack3, Attack4)
% attack(Nome, Tipo, Categoria, Poder, Precisão, PP, MaxPP, Critico)
% pokemon_battle(Pokemon, CurrentHP, Atk1, Atk2, Atk3, Atk4, Condicao)

% Carrega o csv de ataques.
carregar_ataques :-
    retractall(attack(_, _, _, _, _, _, _, _)), % Limpa a base de ataques
    csv_read_file('modules/data/ataques.csv', LinhasAtaques, [skip_header(true)]),
    maplist(processar_linha_ataque, LinhasAtaques).

% Processa os ataques.
processar_linha_ataque(row(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico)) :-
    assertz(attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico)).

% Carrega o csv de pokemons.
carregar_pokemons :-
    retractall(pokemon(_, _, _, _, _, _, _, _, _, _, _, _, _)), % Limpa a base dos pokémons.
    csv_read_file('modules/data/pokemon.csv', LinhasPokemons, [skip_header(true)]),
    maplist(processar_linha_pokemon, LinhasPokemons).

% Processa os pokémons
processar_linha_pokemon(row(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Atk1, Atk2, Atk3, Atk4)) :-
    assertz(pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Atk1, Atk2, Atk3, Atk4)).

% Gera pokemon_battle inicial a partir de um Pokémon
gera_pokemon_battle_inicial(NomePokemon) :-
    pokemon(NomePokemon, T1, T2, HP, FAtk, FDef, SAtk, SDef, Spd, A1, A2, A3, A4),
    buscar_ataque(A1, Atk1),
    buscar_ataque(A2, Atk2),
    buscar_ataque(A3, Atk3),
    buscar_ataque(A4, Atk4),
    assertz(pokemon_battle(
        pokemon(NomePokemon, T1, T2, HP, FAtk, FDef, SAtk, SDef, Spd, A1, A2, A3, A4),
        HP,
        Atk1,
        Atk2,
        Atk3,
        Atk4,
        ''
    )).

% Busca ataque
buscar_ataque(Nome, Attack) :-
    attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico),
    Attack = attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico).

% Inicialização completa
carregar_tudo :-
    carregar_pokemons,
    carregar_ataques.

main :-
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
    
    % Mostra o Pokémon em batalha
    writeln('\n=== Estado da Batalha =='),
    pokemon_battle(Pokemon, HP, Atk1, Atk2, Atk3, Atk4, Condicao),
    write('Pokémon: '), writeln(Pokemon),
    write('HP: '), writeln(HP),
    write('Ataque 1: '), writeln(Atk1),
    write('Condição: '), writeln(Condicao),
    
    writeln('\n=== Fim do Teste ===').
