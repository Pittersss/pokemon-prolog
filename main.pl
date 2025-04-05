:- use_module(library(csv)).
:- dynamic pokemon/13, attack/8, pokemon_battle/8.

% pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Attack1, Attack2, Attack3, Attack4)
% attack(Nome, Tipo, Categoria, Poder, Precisão, PP, MaxPP, Critico)
% pokemon_battle(Nome, Pokemon, CurrentHP, Pp_Atk1, Pp_Atk2, Pp_Atk3, Pp_Atk4, Condicao)

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
    attack(A1,_,_,_,_,_,Pp_Atk1,_),
    attack(A2,_,_,_,_,_,Pp_Atk2,_),
    attack(A3,_,_,_,_,_,Pp_Atk3,_),
    attack(A4,_,_,_,_,_,Pp_Atk4,_),
    assertz(pokemon_battle(
        NomePokemon,
        pokemon(NomePokemon, T1, T2, HP, FAtk, FDef, SAtk, SDef, Spd, A1, A2, A3, A4),
        HP,
        Pp_Atk1,
        Pp_Atk2,
        Pp_Atk3,
        Pp_Atk4,
        ''
    )).

% Busca ataque
buscar_ataque(Nome, Attack) :-
    attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico),
    Attack = attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico).

buscar_pokemon(Nome, Pokemon):-
    pokemon(Nome, Tipo1, Tipo2, Hp, Fatk, Fdef, Satk, Sdef, Spd, Atk1, Atk2, Atk3, Atk4),
    Pokemon = pokemon(Nome, Tipo1, Tipo2, Hp, Fatk, Fdef, Satk, Sdef, Spd, Atk1, Atk2, Atk3, Atk4).

% Pega Hp de um pokemon
get_Hp_max(Nome, Hp):-
    pokemon_battle(Nome, pokemon(Nome,_,_,Hp,_,_,_,_,_,_,_,_,_),_,_,_,_,_,_).

get_Hp(Nome, Hp):-
    pokemon_battle(Nome, pokemon(Nome,_,_,_,_,_,_,_,_,_,_,_,_),Hp,_,_,_,_,_).

% Pega Spd de um pokemon
get_Spd(Nome, Spd):-
    pokemon_battle(Nome, pokemon(Nome,_,_,_,_,_,_,_,Spd,_,_,_,_),_,_,_,_,_,_).

% Decide qual pokemon vai primeiro
quem_vai_primeiro(Nome1, Nome2, 1):-
    get_Spd(Nome1, Spd1), get_Spd(Nome2, Spd2), Spd1 >= Spd2.

quem_vai_primeiro(Nome1, Nome2, 2):-
    get_Spd(Nome1, Spd1), get_Spd(Nome2, Spd2), Spd1 =< Spd2.

calculaEficiencia('Agua','Fogo',2.0):-!.
calculaEficiencia('Fogo','Agua',0.5):-!.
calculaEficiencia('Fogo','Grama',2.0):-!.
calculaEficiencia('Grama','Fogo',0.5):-!.
calculaEficiencia('Grama','Agua',2.0):-!.
calculaEficiencia('Agua','Grama',0.5):-!.
calculaEficiencia('Gelo','Terra',2.0):-!.
calculaEficiencia('Terra','Eletrico',2.0):-!.
calculaEficiencia('Eletrico','Voador',2.0):-!.
calculaEficiencia('Voador','Lutador',2.0):-!.
calculaEficiencia('Lutador','Voador',0.5):-!.
calculaEficiencia('Lutador','Gelo',2.0):-!.
calculaEficiencia('Dragao','Dragao',2.0):-!.
calculaEficiencia('Fantasma','Fantasma',2.0):-!.
calculaEficiencia('Inseto','Psiquico',2.0):-!.
calculaEficiencia('Veneno','Grama',2.0):-!.
calculaEficiencia('Grama','Veneno',0.5):-!.
calculaEficiencia('Grama','Terra',2.0):-!.
calculaEficiencia('Terra','Fogo',2.0):-!.
calculaEficiencia('Fogo','Gelo',2.0):-!.
calculaEficiencia('Gelo','Fogo',0.5):-!.
calculaEficiencia('Gelo','Voador',2.0):-!.
calculaEficiencia('Voador','Inseto',2.0):-!.
calculaEficiencia('Inseto','Voador',0.5):-!.
calculaEficiencia('Inseto','Grama',2.0):-!.
calculaEficiencia('Grama','Inseto',0.5):-!.
calculaEficiencia('Agua','Pedra',2.0):-!.
calculaEficiencia('Eletrico','Agua',2.0):-!.
calculaEficiencia('Lutador','Normal',2.0):-!.
calculaEficiencia('Fantasma','Psiquico',2.0):-!.
calculaEficiencia('Pedra','Inseto',2.0):-!.
calculaEficiencia('Eletrico','Terra',0.0):-!.
calculaEficiencia('Normal','Fantasma',0.0):-!.
calculaEficiencia('Lutador','Fantasma',0.0):-!.
calculaEficiencia('Terra','Voador',0.0):-!.
calculaEficiencia('Fogo','Dragao',0.5):-!.
calculaEficiencia('Agua','Dragao',0.5):-!.
calculaEficiencia('Grama','Dragao',0.5):-!.
calculaEficiencia('Voador','Grama',2.0):-!.
calculaEficiencia(_, _, 1.0).

% Calcula eficiência de um ataque contra um pokemon
eficiencia(TipoAtk, Tipo1, Tipo2, R):- 
    calculaEficiencia(TipoAtk, Tipo1, R1), calculaEficiencia(TipoAtk, Tipo2, R2), 
    R is R1*R2.

% Determina se um golpe é super efetivo ou não
eh_super_efetivo(TipoAtk, Tipo1, Tipo2, R):-
    eficiencia(TipoAtk, Tipo1, Tipo2, R1), 
    R1 >= 2.0 -> R = true; R = false.

% Determina a condição obtida através de um ataque
determina_condicao('Veneno','Envenenado'):-!.
determina_condicao('Eletrico','Paralisado'):-!.
determina_condicao('Gelo','Congelado'):-!.
determina_condicao('Psiquico','Sonolento'):-!.
determina_condicao('Fogo','Queimando'):-!.
determina_condicao(_,'').

% Determina se um golpe é crítico ou não
calcula_critico(N,R):-
    random_1_to_100(N1),
    R1 is N*4,
    N1 < R1 -> R = true; R = false.

% Calcula aleatoriedade do dano de um golpe
calcula_random_golpe(R):-
    random_between(80,100,R1),
    R is R1/100

% Determinar se um ataque aplica efeito negativo
pode_aplicar_status(R):-
    random_1_to_100(R1),
    R1 =< 10 -> R = true; R = false.

random_1_to_100(R) :-
    random_between(1, 100, R).

% Inicialização completa
carregar_tudo :-
    carregar_pokemons,
    carregar_ataques.

% Função que determina se um golpe acerta
calcula_acerto(C, R):-
    random_1_to_100(R1),
    C >= R1 -> R = true; R = false.

% Calcula o novo hp de um pokemon
calcula_hp(CurrentHP, MaxHP, Change, NewHP) :-
    TempHP is CurrentHP + Change,
    (   TempHP =< 0        -> NewHP is 0
    ;   TempHP >= MaxHP    -> NewHP is MaxHP
    ;   NewHP is TempHP
    ).

% Atualiza a vida de um pokemon
altera_hp(Nome, Vida) :-
    get_Hp(Nome, HP),
    get_Hp_max(Nome, HP_max),
    calcula_hp(HP, HP_max, Vida, Nova_vida),
    pokemon_battle(Nome, Pokemon, _, Atk1, Atk2, Atk3, Atk4, Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, Pokemon, Nova_vida, Atk1, Atk2, Atk3, Atk4, Condicao)).

calculate_damage(Attack, Defense, Power, Stab, TypeEffectiveness, Burn, Critical, Damage) :-
    BaseMultiplier is ((50 * 2 / 5) + 2),
    AttackDefenseRatio is Attack / Defense,
    UnmodifiedDamage is ((BaseMultiplier * Power * AttackDefenseRatio) / 50 + 2),
    Damage is UnmodifiedDamage * Stab * TypeEffectiveness * Burn * Critical.

% pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Attack1, Attack2, Attack3, Attack4)
% attack(Nome, Tipo, Categoria, Poder, Precisão, PP, MaxPP, Critico)
% pokemon_battle(Nome, Pokemon, CurrentHP, Pp_Atk1, Pp_Atk2, Pp_Atk3, Pp_Atk4, Condicao)

realiza_ataque(Nome1, Nome2, NumAtk):-
    NumAtk >= 1, NumAtk =< 4,
    pokemon_battle(Nome1, pokemon(Nome1,_,_,_,Fatk1,_,Satk1,_,Spd1,Atk1,Atk2,Atk3,Atk4),Cur_Hp1,Pp_Atk1,Pp_Atk2,Pp_Atk3,Pp_Atk4,Condicao1),
    pokemon_battle(Nome1, pokemon(Nome1,Tipo1,Tipo2,Hp2,_,Fdef2,_,Sdef2,Spd2,_,_,_,_),Cur_Hp2,_,_,_,_,Condicao2),

    NumAtk =:= 1 -> attack(Atk1,TipoAtk,Categoria,Poder,Precisao,PP,MaxPP,Critico)
    (
        NumAtk =:= 2 -> attack(Atk2,TipoAtk,Categoria,Poder,Precisao,PP,MaxPP,Critico)
        (
            NumAtk =:= 3 -> attack(Atk3,TipoAtk,Categoria,Poder,Precisao,PP,MaxPP,Critico); 
                attack(Atk4,TipoAtk,Categoria,Poder,Precisao,PP,MaxPP,Critico)
        )
    )

    calcula_acerto(Precisao,Resultado_acerto),
    
    Cur_Hp1 < 0 -> !;
    (
        Resultado_acerto == false -> !; 
        (
        calcula_critico(Critico,Resultado_critico),
        pode_aplicar_status(R),
        (R == true,Condicao2 == '')-> determina_condicao(TipoAtk, New_Condicao); determina_condicao('', New_Condicao),

        Categoria == 'Fisico' -> (Status_atk is Fatk1, Status_def is Fdef2); (Status_atk is Satk1, Status_def is Sdef2),
        
        ).
    )

main:-
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
    gera_pokemon_battle_inicial('Pidgeot'),
 
    % Fazendo testes     

    quem_vai_primeiro('Pikachu','Pidgeot',X),
    writeln(X),

    eficiencia('Fogo','Agua','Eletrico', R),
    writeln(R),

    eh_super_efetivo('Fogo','Agua','Eletrico',R1),
    writeln(R1),

    altera_hp('Pidgeot',-30),
    get_Hp('Pidgeot',A),
    writeln(A),

    % Mostra o Pokémon em batalha
    writeln('\n=== Estado da Batalha =='),
    pokemon_battle(Nome, Pokemon, HP, Atk1, Atk2, Atk3, Atk4, Condicao),
    write('Pokémon: '), writeln(Pokemon),
    write('HP: '), writeln(HP),
    write('Ataque 1: '), writeln(Atk1),
    write('Condição: '), writeln(Condicao),
    
    writeln('\n=== Fim do Teste ===').
