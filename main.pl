:- use_module(library(csv)).
:- dynamic pokemon/13, attack/8, pokemon_battle/8.

% pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Attack1, Attack2, Attack3, Attack4)
% attack(Nome, Tipo, Categoria, Poder, Precisão, PP, MaxPP, Critico)
% pokemon_battle(Nome, Pokemon, CurrentHP, Pp_Atk1, Pp_Atk2, Pp_Atk3, Pp_Atk4, Condicao)

item('Hyper Potion',5).
item('Full Restore',5).

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
    random_between(1, 100, N1),
    R1 is N*4,
    N1 < R1 -> R = true; R = false.

% Calcula aleatoriedade do dano de um golpe
calcula_random_golpe(R):-
    random_between(80,100,R1),
    R is R1/100.

% Inicialização completa
carregar_tudo :-
    carregar_pokemons,
    carregar_ataques.

% Função que determina se um golpe acerta
calcula_acerto(C, R):-
    random_between(1, 100, R1),
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

calculate_damage(Attack, Defense, Power, Stab, TypeEffectiveness, Burn, Critical, Damage):-
    BaseMultiplier is ((50 * 2 / 5) + 2),
    AttackDefenseRatio is Attack / Defense,
    UnmodifiedDamage is ((BaseMultiplier * Power * AttackDefenseRatio) / 50 + 2),
    Dmg is UnmodifiedDamage * Stab * TypeEffectiveness * Burn * Critical * -1,
    Damage is round(Dmg).

altera_condicao(Nome, Condicao):-
    pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4, _),
    retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 1):- 
    pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
    N_Atk1 is Atk1-1,
    assertz(pokemon_battle(Nome, Pokemon, Hp, N_Atk1, Atk2, Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 2):- 
    pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
    N_Atk2 is Atk2-1,
    assertz(pokemon_battle(Nome, Pokemon, Hp, Atk1, N_Atk2, Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 3):- 
    pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
    N_Atk3 is Atk3-1,
    assertz(pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, N_Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 4):- 
    pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
    N_Atk4 is Atk4-1,
    assertz(pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, N_Atk4, Condicao)).

utiliza_item(NomePkm, NomeItm):-
        pokemon_battle(Nome, Pokemon, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
        retract(pokemon_battle(Nome, _, _, _, _, _, _, _)),
        NomeItm == 'Hyper Potion' -> altera_hp(NomePkm,120);
        (
            NomeItm == 'Full Restore' -> altera_condicao(NomePkm,'');!
        ).

choose_attack(NumAtk, Atk1, Atk2, Atk3, Atk4, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico) :-
    NumAtk =:= 1 -> attack(Atk1, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico);
    NumAtk =:= 2 -> attack(Atk2, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico);
    NumAtk =:= 3 -> attack(Atk3, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico);
    attack(Atk4, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico).

determina_critico(Critico, Critical):-
     calcula_critico(Critico,Resultado_critico),
     Resultado_critico == true -> Critical is 1.5; Critical is 1.0.

determina_status(Condicao, TipoAtk, New_Condicao):-
    random_between(1,100, R),
    (R =< 10 -> R1 = true; R1 = false),
    determina_status_aux(Condicao, TipoAtk, New_Condicao, R1).

determina_status_aux(Condicao, _, Condicao, false):-!.
determina_status_aux(Condicao, _, Condicao, true):- Condicao \= '', !.
determina_status_aux('', TipoAtk, New_Condicao, true):- determina_condicao(TipoAtk, New_Condicao).

determina_condicao_negativa('Queimando', 'Fisico', 0,5):-!.
determina_condicao_negativa('Congelado', 'Fisico', 0,5):-!.
determina_condicao_negativa('Paralisado', 'Especial', 0,5):-!.
determina_condicao_negativa('Envenenado', 'Especial', 0,5):-!.
determina_condicao_negativa('Sonolento', _, 0.75):-!.
determina_condicao_negativa(_,_,1.0):-!.

realiza_ataque(Nome1, Nome2, NumAtk):-
    NumAtk >= 1, NumAtk =< 4,
    pokemon_battle(Nome1, pokemon(Nome1,Tipo1,Tipo2,_,Fatk1,_,Satk1,_,Spd1,Atk1,Atk2,Atk3,Atk4),Cur_Hp1,Pp_Atk1,Pp_Atk2,Pp_Atk3,Pp_Atk4,Condicao1),
    pokemon_battle(Nome2, pokemon(Nome2,Tipo3,Tipo4,Hp2,_,Fdef2,_,Sdef2,Spd2,_,_,_,_),Cur_Hp2,_,_,_,_,Condicao2),    
    choose_attack(NumAtk, Atk1, Atk2, Atk3, Atk4, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico),
    
    (Cur_Hp1 =< 0 -> !;
        (Resultado_acerto == false -> !;
            (PP =< 0 -> !;
                determina_critico(Critico, Critical),
                determina_status(Condicao2, TipoAtk, New_Condicao),
                determina_condicao_negativa(Condicao1, Categoria, Condicao_negativa),
                eficiencia(TipoAtk, Tipo1, Tipo2, Eficiencia),

                (Categoria == 'Fisico' -> (Status_atk is Fatk1, Status_def is Fdef2); (Status_atk is Satk1, Status_def is Sdef2)),
                (TipoAtk == Tipo1 -> Stab is 1.5; (TipoAtk == Tipo2 -> Stab is 1.5; Stab is 1.0)),
                calculate_damage(Status_atk, Status_def, Poder, Stab, Eficiencia, Condicao_negativa, Critical, Damage),

                altera_hp(Nome2,Damage),
                altera_condicao(Nome2, New_condicao),
                subtrai_pp(Nome1, NumAtk)
            )
        )
    ).


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
    gera_pokemon_battle_inicial('Charizard'),
 
    % Fazendo testes     

    % Mostra o Pokémon em batalha
    writeln('\n=== Estado da Batalha =='),
    pokemon_battle('Charizard', Pokemon, HP, Atk1, Atk2, Atk3, Atk4, Condicao),
    write('Pokémon: '), writeln(Pokemon),
    write('HP: '), writeln(HP),
    write('Ataque 1: '), writeln(Atk1),
    write('Condição: '), writeln(Condicao),
    writeln('\n=== Fim do Teste ==='),

    writeln('\n===Teste de Batalha==='),
    realiza_ataque('Pikachu','Charizard', 4),
    pokemon_battle('Charizard',_,Hp_Atual,_,_,_,_,_),
    writeln("Hp antigo é: "),
    writeln(HP),
    writeln("Hp atual é: "),
    writeln(Hp_Atual),
    realiza_ataque('Pikachu','Charizard', 2),
    pokemon_battle('Charizard',_,New_Hp_atual,_,_,_,_,_),
    writeln("Novo Hp é: "),
    writeln(New_Hp_atual).


