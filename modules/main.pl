:- use_module(library(csv)), writeln('eu n sei oq fazer pra importar direito, essa bomba so roda com isso ignore a mensagem de erro ele ta rodando!!').
:- use_module(historico).
:- dynamic pokemon/13, attack/8, pokemon_battle/7, item/2.

% pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Attack1, Attack2, Attack3, Attack4)
% attack(Nome, Tipo, Categoria, Poder, Precisão, PP, MaxPP, Critico)
% pokemon_battle(Pokemon, CurrentHP, Atk1, Atk2, Atk3, Atk4, Condicao)
% item(Nome, Qtd)

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
        NomePokemon,
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

% Inicia os itens
iniciar_itens :-
    retractall(item(_,_)),
    assertz(item('Hyper Potion', 5)),
    assertz(item('Full Restore', 10)).

get_Hp_max(Nome, HP):- pokemon(Nome, _, _, HP, _, _, _, _, _, _, _, _, _).

calcula_hp(CurrentHP, MaxHP, Change, NewHP) :-
    TempHP is CurrentHP + Change,
    (   TempHP =< 0        -> NewHP is 0
    ;   TempHP >= MaxHP    -> NewHP is MaxHP
    ;   NewHP is TempHP
    ).

% Atualiza a vida de um pokemon
altera_hp(Nome, Vida) :-
    pokemon_battle(Nome, HP, Atk1, Atk2, Atk3, Atk4, Condicao),
    get_Hp_max(Nome, HP_max),
    calcula_hp(HP, HP_max, Vida, Nova_vida),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, Nova_vida, Atk1, Atk2, Atk3, Atk4, Condicao)).

altera_condicao(Nome):- 
    pokemon_battle(Nome, HP, Atk1, Atk2, Atk3, Atk4, _),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, HP, Atk1, Atk2, Atk3, Atk4, '')).

utiliza_item(NomePkm, NomeItm):-
        pokemon_battle(NomePkm,Hp,_,_,_,_,Condicao),
        item(NomeItm,Qtd),
        Qtd > 0, % melhor checar a quantidade no momento de batalha, pq aqui ele só para sem retornar false.
        NovaQtd is Qtd - 1,
        retract(item(NomeItm,_)),
        assertz(item(NomeItm,NovaQtd)),
        NomeItm == 'Hyper Potion' -> altera_hp(NomePkm,120);
        (
            NomeItm == 'Full Restore' -> altera_condicao(NomePkm);!
        ).

% tira hp e aplica Condicao pra testar se os itens estao funcionando
testehyper(Nome):-
    pokemon_battle(Nome, HP, Atk1, Atk2, Atk3, Atk4, _),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, HP, Atk1, Atk2, Atk3, Atk4, 'uiii')).

testefull(Nome):-
    pokemon_battle(Nome, _, Atk1, Atk2, Atk3, Atk4, Cond),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, 1, Atk1, Atk2, Atk3, Atk4, Cond)).

% Inicialização completa
carregar_tudo :-
    carregar_pokemons,
    carregar_ataques,
    iniciar_placar,
    iniciar_itens.

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
    
    writeln('\n=== Itens Carregados =='),
    findall((Nome,Qtd), item(Nome,Qtd), ListaItens),
    write('Itens: '), writeln(ListaItens),

    % Testa a criação de uma batalha
    writeln('\n=== Teste de Batalha =='),
    gera_pokemon_battle_inicial('Pikachu'),
    
    % Mostra o Pokémon em batalha
    writeln('\n=== Estado da Batalha =='),
    pokemon_battle('Pikachu', HP, Atk1, Atk2, Atk3, Atk4, Condicao),
    write('Pokémon: '), writeln('Pikachu'),
    write('HP: '), writeln(HP),
    write('Ataque 1: '), writeln(Atk1),
    write('Condição: '), writeln(Condicao),
    
    writeln('\n=== Estatisticas =='),
    get_estatisticas(X), writeln(X), 
    incrementa_derrota, incrementa_derrota, incrementa_vitoria, 
    writeln('Acrescido 3 partidas e 1 vitoria:'),
    get_estatisticas(Y), writeln(Y),

    writeln('\n=== Teste de uso de itens =='),
    gera_pokemon_battle_inicial('Charizard'),
    pokemon_battle('Charizard', PHP, PAtk1, PAtk2, PAtk3, PAtk4, PCondicao),
    write('Antes:::::::::::::\nPokémon: Charizard'),
    write('\nHP: '), writeln(PHP),
    write('Condição: '), writeln(PCondicao),
    testefull('Charizard'),
    testehyper('Charizard'),
    pokemon_battle('Charizard', P1HP, P1Atk1, P1Atk2, P1Atk3, P1Atk4, P1Condicao),
    write('\nDurante:::::::::::::::::::'),
    write('\nHP: '), writeln(P1HP),
    write('Condição: '), writeln(P1Condicao),
    utiliza_item('Charizard', 'Hyper Potion'),
    utiliza_item('Charizard', 'Full Restore'),
    pokemon_battle('Charizard', P2HP, P2Atk1, P2Atk2, P2Atk3, P2Atk4, P2Condicao),
    write('\nDepois::::::::::::'),
    write('\nHP: '), writeln(P2HP),
    write('Condição: '), writeln(P2Condicao),
    findall((Nome,Qtd), item(Nome,Qtd), ListaItens2),
    write('Itens: '), writeln(ListaItens2),
    
    writeln('\n=== Fim do Teste ===').