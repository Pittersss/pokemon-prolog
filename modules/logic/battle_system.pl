:- module(battle_system, [battle/2, pokemons_disponiveis/1, processar_entrada/2]).
:- use_module('pokemon').

% Extrai o primeiro Pokémon da lista
active_pokemon([Pokemon|Rest], Pokemon, Rest).

% Inicia a batalha
battle(TimeUser, TimeBot) :-
    battle_system(TimeUser, TimeBot),
    !.

% Condições de fim da batalha
battle_system([], _) :-
    format('Você perdeu a batalha!~n'), !.
battle_system(_, []) :-
    format('Você venceu a batalha!~n'), !.

% Fluxo da batalha
battle_system(TeamUser, TeamBot) :-
    active_pokemon(TeamUser, UserPkm, RestUser),
    active_pokemon(TeamBot, BotPkm, RestBot),
    format('Iniciando duelo entre ~w e ~w~n', [UserPkm, BotPkm]),
    battle_pokemon(UserPkm, BotPkm, Winner, RestUser, NewRestUser, TeamBot, NewTeamBot),
    ( Winner = BotPkm ->
         format('Seu Pokémon ~w morreu!~n', [UserPkm]),
         battle_system(NewRestUser, NewTeamBot)
    ; Winner = UserPkm ->
         format('O Pokémon do Bot ~w morreu!~n', [BotPkm]),
         battle_system(TeamUser, RestBot)
    ; % Caso especial de troca
         true
    ).

% Turno com possibilidade de ataque, uso de item ou troca
battle_pokemon(UserPkm, BotPkm, Winner, RestUser, NewRestUser, TeamBot, TeamBot) :-
    get_Hp(UserPkm, HPUser),
    get_Hp(BotPkm, HPBot),
    ( HPUser =< 0 ->
         Winner = BotPkm, !
    ; HPBot =< 0 ->
         Winner = UserPkm, !
    ;
        infoBtl(UserPkm, BotPkm),
        writeln('O que deseja fazer?'),
        writeln('1. Atacar'),
        writeln('2. Usar item'),
        writeln('3. Trocar de Pokémon'),
        read(Opcao),
        ( Opcao =:= 2 ->
              writeln('Qual item deseja usar?'),
              writeln('1. Hyper Potion'),
              writeln('2. Full Restore'),
              read(EscolhaItem),
              (EscolhaItem =:= 1 -> Resultado = 'Hyper Potion' ; Resultado = 'Full Restore'),
              usar_item(UserPkm, Resultado),
              format('Você usou um item: ~w~n', [Resultado]),
              battle_pokemon(UserPkm, BotPkm, Winner, RestUser, NewRestUser, TeamBot, TeamBot)
        ; Opcao =:= 3 ->
              gira_lista([UserPkm | RestUser], NewUserTeam),
              format('Você trocou de Pokémon!~n'),
              battle_system(NewUserTeam, [BotPkm | []]),
              !, fail
        ;
            imprimeAtaques(UserPkm),
            write('Escolha seu ataque (1-4): '),
            read(UserAttack),
            realiza_ataque(UserPkm, BotPkm, UserAttack),
            get_Hp(BotPkm, NewHPBot),
            format('Após seu ataque, HP de ~w: ~w~n', [BotPkm, NewHPBot]),
            flush_output(user_output),
            ( NewHPBot =< 0 ->
                Winner = UserPkm,
                NewRestUser = RestUser
            ;
                % Turno do Bot
                infoBtl(UserPkm, BotPkm),
                format('Bot ~w ataca agora!~n', [BotPkm]),
                imprimeAtaques(BotPkm),
                random_between(1, 4, BotAttack),
                realiza_ataque(BotPkm, UserPkm, BotAttack),
                get_Hp(UserPkm, NewHPUser),
                format('Após o ataque do Bot, HP de ~w: ~w~n', [UserPkm, NewHPUser]),
                flush_output(user_output),
                ( NewHPUser =< 0 ->
                    Winner = BotPkm,
                    NewRestUser = RestUser
                ;
                    battle_pokemon(UserPkm, BotPkm, Winner, RestUser, NewRestUser, TeamBot, TeamBot)
                )
            )
        )
    ).

% Exibe o estado atual da batalha
infoBtl(UsuPkmn, EnPkmn):-
    pokemon_battle(UsuPkmn, UHP, _, _, _, _, UCond),
    pokemon_battle(EnPkmn, EHP, _, _, _, _, ECond),
    writeln('\n=============================='),
    format('Seu Pokémon: ~w\nHP: ~w\nCondição: ~w\n', [UsuPkmn, UHP, UCond]),
    writeln('------------------------------'),
    format('Pokémon do Bot: ~w\nHP: ~w\nCondição: ~w\n', [EnPkmn, EHP, ECond]),
    writeln('==============================\n').

% Exibe ataques disponíveis
imprimeAtaques(Pkmn):-
    pokemon(Pkmn, _, _, _, _, _, _, _, _, Atk1, Atk2, Atk3, Atk4),
    pokemon_battle(Pkmn, _, PP1, PP2, PP3, PP4, _),
    attack(Atk1, _, _, _, _, _, MaxPP1, _),
    attack(Atk2, _, _, _, _, _, MaxPP2, _),
    attack(Atk3, _, _, _, _, _, MaxPP3, _),
    attack(Atk4, _, _, _, _, _, MaxPP4, _),
    writeln('\n=============================='),
    format('1. ~w, ~w/~w\n2. ~w, ~w/~w\n3. ~w, ~w/~w\n4. ~w, ~w/~w', 
           [Atk1, PP1, MaxPP1, Atk2, PP2, MaxPP2, Atk3, PP3, MaxPP3, Atk4, PP4, MaxPP4]),
    writeln('\n==============================\n').

% Lista de opções de Pokémon
num_pokemon(1, 'Charizard').
num_pokemon(2, 'Blastoise').
num_pokemon(3, 'Venusaur').
num_pokemon(4, 'Pikachu').
num_pokemon(5, 'Butterfree').
num_pokemon(6, 'Alakazam').
num_pokemon(7, 'Gengar').
num_pokemon(8, 'Onix').
num_pokemon(9, 'Seadra').
num_pokemon(10, 'Hitmonlee').

pokemons_disponiveis(Selecionados):-
     writeln('Escolha o seu time de 6 Pokémons:\n1. Charizard\n2. Blastoise\n3. Venusaur\n4. Pikachu\n5. Butterfree\n6. Alakazam\n7. Gengar\n8. Onix\n9. Seadra\n10. Hitmonlee\n'),
     read_line_to_string(user_input, Input),
     processar_entrada(Input, Selecionados).

processar_entrada(Input, Selecionados):-
     split_string(Input, " ", "", Partes),
     (length(Partes, 6), converter_validar(Partes,SelecionadosNum) -> 
          maplist(num_pokemon, SelecionadosNum, Selecionados)
          ;
          writeln('\nEntrada inválida! Tente novamente.'),
          pokemons_disponiveis(Selecionados)
     ).

converter_validar([], []).
converter_validar([P|Ps], [N|Ns]) :-
    atom_number(P, N),
    integer(N),
    between(1, 10, N),
    converter_validar(Ps, Ns).

% Gira a lista colocando o primeiro no final
gira_lista([Head|Tail], NewList) :-
    append(Tail, [Head], NewList).
