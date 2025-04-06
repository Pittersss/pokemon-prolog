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

utiliza_item(NomePkm, 1):-
        pokemon_battle(NomePkm,Hp,_,_,_,_,Condicao),
        item(NomeItm,Qtd),
        Qtd > 0, % melhor checar a quantidade no momento de batalha, pq aqui ele só para sem retornar false.
        NovaQtd is Qtd - 1,
        retract(item(NomeItm,_)),
        assertz(item(NomeItm,NovaQtd)),
        altera_hp(NomePkm,120).

utiliza_item(NomePkm, 2):-
        pokemon_battle(NomePkm,Hp,_,_,_,_,Condicao),
        item(NomeItm,Qtd),
        Qtd > 0, % melhor checar a quantidade no momento de batalha, pq aqui ele só para sem retornar false.
        NovaQtd is Qtd - 1,
        retract(item(NomeItm,_)),
        assertz(item(NomeItm,NovaQtd)),
        altera_condicao(NomePkm).

% Inicialização completa
carregar_tudo :-
    carregar_pokemons,
    carregar_ataques,
    iniciar_placar,
    iniciar_itens.

% Transforma os nomes de uma lista em pokemon_battle.
gera_pokemons_battle(ListaPokemons):-
    maplist(gera_pokemon_battle_inicial, ListaPokemons).

% Coloca o próximo pokémon disponível
gira_lista([Head|Tail], Lista):-
    append(Tail, Head, Lista).

% Permite o usuário escolher um ataque
escolha_aliado([PkmnAtual|Pkmns], [EnAtual|EnPkmns],1):-
    pokemon(PkmnAtual, _, _, _, _, _, _, _, _, Atk1,Atk2,Atk3,Atk4),
    pokemon_battle(PkmnAtual,_,PP1,PP2,PP3,PP4,_),
    format('escolha o ataque:\n1: ~w - ~w\n2: ~w - ~w\n3: ~w - ~w\n4: ~w - ~w\n', [Atk1,PP1,Atk2,PP2,Atk3,PP3,Atk4,PP4]),
    read(X),
    (writeln('ataque aqui'),
    turn_inimigo([PkmnAtual|Pkmns], [EnAtual|EnPkmns]) ; 
        writeln('escolha errada, escolha de novo'), 
        turn_aliado_choice([PkmnAtual|Pkmns], [EnAtual|EnPkmns])).

% Permite o usuário escolher um item
escolha_aliado([PkmAtual|Pkmns], [EnAtual|EnPkmns],2):-
    findall(Qtd, item(Nome,Qtd),Qtds),
    format('escolha o item:\n1. Hyper Potion - ~w\n2. Full Restore - ~w\n', Qtds),
    read(X),
    (utiliza_item(PkmAtual,X), turn_inimigo([PkmAtual|Pkmns], [EnAtual|EnPkmns]) ; 
        writeln('esgotado! escolha novamente'), turn_aliado_choice([PkmAtual|Pkmns], [EnAtual|EnPkmns])).

% Se só tiver 1 pokémon, não pode mudar.
escolha_aliado([Head|[]],EnPkmns,3):- 
    writeln('não eh possivel trocar de pokemon :('),
    turn_aliado_choice([Head|[]],EnPkmns).

% Muda pro próximo pokémon disponível
escolha_aliado(UsuPkmns, EnPkmns,3):-
    gira_lista(UsuPkmns, [NovoPkmn|Tail]),
    format('eu escolho vc ~w!!\n', [NovoPkmn]),
    turn_inimigo(UsuPkmns, EnPkmns).

% Entrada inválida
escolha_aliado(UsuPkmns, EnPkmns,_):-
    writeln('escolha de novo'),
    turn_aliado_choice(UsuPkmns, EnPkmns).

% Menu de escolhas do usuário
turn_aliado_choice(UsuPkmns, EnPkmns):-
    % printar os dados dos 2 pokemons aqui
    writeln('escolha 1:ataque 2:item 3:mudar pokemon'),
    read(X),
    escolha_aliado(UsuPkmns, EnPkmns, X).

% Turn do inimigo
turn_inimigo(UsuPkmns, EnPkmns):-
    writeln('nada ainda').

main:-
    carregar_tudo,
    X = ['Pidgeot', 'Charizard', 'Pikachu', 'Onix', 'Slowbro'],
    Y = ['Butterfree', 'Hitmonlee', 'Cloyster', 'Seadra', 'Gengar'],
    gera_pokemons_battle(X),
    gera_pokemons_battle(Y),
    % aqui faz um if pra ver quem vai primeiro
    turn_aliado_choice(X,Y).