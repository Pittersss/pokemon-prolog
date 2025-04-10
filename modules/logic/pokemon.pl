:- module(pokemon, [
    iniciar_itens/0,
    carregar_tudo/0,
    carregar_ataques/0,
    processar_linha_ataque/1,
    carregar_eficiencias/0,
    processar_linha_eficiencia/1,
    carregar_pokemons/0,
    processar_linha_pokemon/1,
    gera_pokemon_battle_inicial/1,
    buscar_ataque/2,
    buscar_pokemon/2,
    get_Hp_max/2,
    get_Hp/2,
    get_Spd/2,
    quem_vai_primeiro/3,
    eh_super_efetivo/4,
    determina_condicao/2,
    calcula_critico/2,
    calcula_random_golpe/1,
    calcula_acerto/2,
    calcula_hp/4,
    altera_hp/2,
    calculate_damage/8,
    altera_condicao/2,
    subtrai_pp/2,
    utiliza_item/2,
    item/2,
    choose_attack/12,
    determina_critico/2,
    determina_status/3,
    determina_status_aux/4,
    determina_condicao_negativa/4,
    realiza_ataque/3,
    pokemon/13,
    attack/8,
    pokemon_battle/7
]).

:- use_module(library(csv)).
:- dynamic pokemon/13, attack/8, pokemon_battle/7, item/2.

% pokemon(Nome, Tipo1, Tipo2, HP, FAtk, FDef, SAtk, SDef, Spd, Attack1, Attack2, Attack3, Attack4)
% attack(Nome, Tipo, Categoria, Poder, Precisão, PP, MaxPP, Critico)
% pokemon_battle(Nome, CurrentHP, Pp_Atk1, Pp_Atk2, Pp_Atk3, Pp_Atk4, Condicao)
% calcula_eficiencia(Tipo1, Tipo2, Valor)

% Função que inicializa os itens no combate
iniciar_itens :-
    retractall(item(_,_)),
    assertz(item('Hyper Potion', 5)),
    assertz(item('Full Restore', 10)).

% Inicialização completa
carregar_tudo :-
    retractall(pokemon_battle(_,_,_,_,_,_,_)),
    carregar_pokemons,
    carregar_eficiencias,
    carregar_ataques.

% Carrega o csv de ataques.
carregar_ataques :-
    retractall(attack(_, _, _, _, _, _, _, _)), % Limpa a base de ataques
    csv_read_file('modules/data/ataques.csv', LinhasAtaques, [skip_header(true)]),
    maplist(processar_linha_ataque, LinhasAtaques).

% Processa os ataques.
processar_linha_ataque(row(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico)) :-
    assertz(attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico)).

% Carrega a base de dados de eficiências
carregar_eficiencias :-
    retractall(calcula_eficiencia(_,_,_)), % Limpa a base de eficiências
    csv_read_file('modules/data/eficiencias.csv', LinhasEficiencia, [skip_header(true)]),
    maplist(processar_linha_eficiencia, LinhasEficiencia).

% Processa as eficiências
processar_linha_eficiencia(row(Tipo1, Tipo2, Valor)) :-
    asserta(calcula_eficiencia(Tipo1, Tipo2, Valor)).

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
    pokemon(NomePokemon, _, _, HP, _, _, _, _, _, A1, A2, A3, A4),
    attack(A1,_,_,_,_,_,Pp_Atk1,_),
    attack(A2,_,_,_,_,_,Pp_Atk2,_),
    attack(A3,_,_,_,_,_,Pp_Atk3,_),
    attack(A4,_,_,_,_,_,Pp_Atk4,_),
    assertz(pokemon_battle(
        NomePokemon,
        HP,
        Pp_Atk1,
        Pp_Atk2,
        Pp_Atk3,
        Pp_Atk4,
        ''
    )).

% Busca ataque com base no nome
buscar_ataque(Nome, Attack) :-
    attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico),
    Attack = attack(Nome, Tipo, Categoria, Poder, Precisao, PP, MaxPP, Critico).

% Busca pokemon com base no nome
buscar_pokemon(Nome, Pokemon):-
    pokemon(Nome, Tipo1, Tipo2, Hp, Fatk, Fdef, Satk, Sdef, Spd, Atk1, Atk2, Atk3, Atk4),
    Pokemon = pokemon(Nome, Tipo1, Tipo2, Hp, Fatk, Fdef, Satk, Sdef, Spd, Atk1, Atk2, Atk3, Atk4).

% Pega Hp maximo de um pokemon
get_Hp_max(Nome, Hp):-
    pokemon(Nome,_,_,Hp,_,_,_,_,_,_,_,_,_).

% Pega hp atual de um pokemon
get_Hp(Nome, Hp):-
    pokemon_battle(Nome, Hp,_,_,_,_,_).

% Pega velocidade de um pokemon
get_Spd(Nome, Spd):-
    pokemon(Nome,_,_,_,_,_,_,_,Spd,_,_,_,_).

% Decide qual pokemon vai primeiro. Se o resultado for 1, é o primeiro; se não, é o segundo.
quem_vai_primeiro(Nome1, Nome2, 1):-
    get_Spd(Nome1, Spd1), get_Spd(Nome2, Spd2), Spd1 >= Spd2.

quem_vai_primeiro(Nome1, Nome2, 2):-
    get_Spd(Nome1, Spd1), get_Spd(Nome2, Spd2), Spd1 =< Spd2.

% Base de dados usada para cálculos de dano

% Calcula eficiência de um ataque contra um pokemon
eficiencia(TipoAtk, Tipo1, Tipo2, R):- 
    write(TipoAtk), write(Tipo1), calcula_eficiencia(TipoAtk, Tipo1, R1),write("Chegou Aqui") calcula_eficiencia(TipoAtk, Tipo2, R2), 
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

% Calcula aleatoriedade do dano de um golpe (todo golpe em pokemon possui um fator aleatório no cálculo de dano)
calcula_random_golpe(R):-
    random_between(80,100,R1),
    R is R1/100.

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
    pokemon_battle(Nome, _, Atk1, Atk2, Atk3, Atk4, Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, Nova_vida, Atk1, Atk2, Atk3, Atk4, Condicao)).

% Função que calcula o dano causado por um ataque
calculate_damage(Attack, Defense, Power, Stab, TypeEffectiveness, Burn, Critical, Damage):-
    BaseMultiplier is ((50 * 2 / 5) + 2),
    AttackDefenseRatio is Attack / Defense,
    UnmodifiedDamage is ((BaseMultiplier * Power * AttackDefenseRatio) / 50 + 2),
    Dmg is UnmodifiedDamage * Stab * TypeEffectiveness * Burn * Critical * -1,
    Damage is round(Dmg).

% Função que altera a condição de um pokemon
altera_condicao(Nome, Condicao):-
    pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, Atk4, _),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    assertz(pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, Atk4, Condicao)).

% Pp é a quantidade de usos disponíveis de um ataque. Subtrair pp significa gastar um uso
subtrai_pp(Nome, 1):- 
    pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    N_Atk1 is Atk1-1,
    assertz(pokemon_battle(Nome, Hp, N_Atk1, Atk2, Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 2):- 
    pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    N_Atk2 is Atk2-1,
    assertz(pokemon_battle(Nome, Hp, Atk1, N_Atk2, Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 3):- 
    pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    N_Atk3 is Atk3-1,
    assertz(pokemon_battle(Nome, Hp, Atk1, Atk2, N_Atk3, Atk4, Condicao)).

subtrai_pp(Nome, 4):- 
    pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, Atk4,Condicao),
    retract(pokemon_battle(Nome, _, _, _, _, _, _)),
    N_Atk4 is Atk4-1,
    assertz(pokemon_battle(Nome, Hp, Atk1, Atk2, Atk3, N_Atk4, Condicao)).

% Função que utiliza um item
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

% Função que carrega informações de ataque
choose_attack(NumAtk, Atk1, Atk2, Atk3, Atk4, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico) :-
    NumAtk =:= 1 -> attack(Atk1, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico);
    NumAtk =:= 2 -> attack(Atk2, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico);
    NumAtk =:= 3 -> attack(Atk3, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico);
    attack(Atk4, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico).

% Função que determina o modificador crítico de um golpe. Se o golpe for crítico, ele causa 1.5x dano
determina_critico(Critico, Critical):-
     calcula_critico(Critico,Resultado_critico),
     Resultado_critico == true -> Critical is 1.5; Critical is 1.0.

% Função que determina se um pokemon que recebeu um ataque adquirirá um efeito de status
determina_status(Condicao, TipoAtk, New_Condicao):-
    random_between(1,100, R),
    (R =< 10 -> R1 = true; R1 = false),
    determina_status_aux(Condicao, TipoAtk, New_Condicao, R1).

determina_status_aux(Condicao, _, Condicao, false):-!.
determina_status_aux(Condicao, _, Condicao, true):- Condicao \= '', !.
determina_status_aux('', TipoAtk, New_Condicao, true):- determina_condicao(TipoAtk, New_Condicao).

% Função que determina os efeitos das condições negativas
determina_condicao_negativa('Queimando', 'Fisico', 0,5):-!.
determina_condicao_negativa('Congelado', 'Fisico', 0,5):-!.
determina_condicao_negativa('Paralisado', 'Especial', 0,5):-!.
determina_condicao_negativa('Envenenado', 'Especial', 0,5):-!.
determina_condicao_negativa('Sonolento', _, 0.75):-!.
determina_condicao_negativa(_,_,1.0):-!.

realiza_ataque(Nome1, Nome2, NumAtk):-
    NumAtk >= 1, NumAtk =< 4,
    pokemon(Nome1,Tipo1,Tipo2,_,Fatk1,_,Satk1,_,Spd1,Atk1,Atk2,Atk3,Atk4),
    pokemon_battle(Nome1, Cur_Hp1,Pp_Atk1,Pp_Atk2,Pp_Atk3,Pp_Atk4,Condicao1),
    pokemon(Nome2,Tipo3,Tipo4,Hp2,_,Fdef2,_,Sdef2,Spd2,_,_,_,_),
    pokemon_battle(Nome2, Cur_Hp2,_,_,_,_,Condicao2),    
    choose_attack(NumAtk, Atk1, Atk2, Atk3, Atk4, TipoAtk, Categoria, Poder, Precisao, PP, MaxPP, Critico),

    (Cur_Hp1 =< 0 -> !;
        (Resultado_acerto == false -> !;
            (PP =< 0 -> !;
                determina_critico(Critico, Critical),
                determina_status(Condicao2, TipoAtk, New_Condicao),
                determina_condicao_negativa(Condicao1, Categoria, Condicao_negativa),
                
                
                (Categoria == 'Fisico' -> (Status_atk is Fatk1, Status_def is Fdef2); (Status_atk is Satk1, Status_def is Sdef2)),
                (TipoAtk == Tipo1 -> Stab is 1.5; (TipoAtk == Tipo2 -> Stab is 1.5; Stab is 1.0)),
                calculate_damage(Status_atk, Status_def, Poder, Stab, 1, Condicao_negativa, Critical, Damage),

                altera_hp(Nome2,Damage),
                altera_condicao(Nome2, New_Condicao),
                subtrai_pp(Nome1, NumAtk)
            )
        )
    ).