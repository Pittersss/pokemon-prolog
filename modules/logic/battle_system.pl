:- module(battle_system, [battle/2, pokemons_disponiveis/1, processar_entrada/2]).
:- use_module('pokemon').  % Certifique-se de que o módulo de lógica dos pokémons esteja disponível

%% active_pokemon(+Time, -Pokemon, -Resto)
%
% Extrai o primeiro Pokémon (ativo) da lista.
active_pokemon([Pokemon|Rest], Pokemon, Rest).

%% battle(+TimeUsuario, +TimeBot)
%
% Inicia a batalha entre os times do usuário e do bot.
% Quando um dos times estiver vazio, exibe a mensagem apropriada.
%
battle(TimeUser, TimeBot) :-
    battle_system(TimeUser, TimeBot),
    !.

%% battle_system(+TeamUser, +TeamBot)
%
% Gerencia o fluxo global da batalha.
% Se o time do usuário for vazio, imprime derrota.
% Se o time do bot for vazio, imprime vitória.
% Caso contrário, extrai os Pokémon ativos e processa o duelo.
%
battle_system([], _) :-
    format('Você perdeu a batalha!~n'),
    !,
    true.
battle_system(_, []) :-
    format('Você venceu a batalha!~n'),
    !,
    true.
battle_system(TeamUser, TeamBot) :-
    active_pokemon(TeamUser, UserPkm, RestUser),
    active_pokemon(TeamBot, BotPkm, RestBot),
    format('Iniciando duelo entre ~w e ~w~n', [UserPkm, BotPkm]),
    battle_pokemon(UserPkm, BotPkm, Winner),
    ( Winner = BotPkm ->
         format('Seu Pokémon ~w morreu!~n', [UserPkm]),
         % Remove o Pokémon do usuário; o time do bot permanece inalterado
         NewTeamUser = RestUser,
         NewTeamBot = TeamBot
    ; Winner = UserPkm ->
         format('O Pokémon do Bot ~w morreu!~n', [BotPkm]),
         % Remove o Pokémon do bot; o time do usuário permanece inalterado
         NewTeamUser = TeamUser,
         NewTeamBot = RestBot
    ),
    battle_system(NewTeamUser, NewTeamBot).

%% battle_pokemon(+UserPkm, +BotPkm, -Winner)
%
% Realiza os turnos de ataque entre os dois Pokémon ativos.
% O Bot sempre ataca primeiro. Após cada ataque, verifica se algum dos
% dois Pokémon foi derrotado (HP <= 0) e, caso contrário, repete o turno.
%
battle_pokemon(UserPkm, BotPkm, Winner) :-
    get_Hp(UserPkm, HPUser),
    get_Hp(BotPkm, HPBot),
    ( HPUser =< 0 ->
         Winner = BotPkm,
         !
    ; HPBot =< 0 ->
         Winner = UserPkm,
         !
    ;
         % Turno do Usuário: solicita escolha do ataque
         infoBtl(UserPkm, BotPkm),
         write('Escolha seu ataque (1-4): '),
         imprimeAtaques(UserPkm),
         read(UserAttack),
         realiza_ataque(UserPkm, BotPkm, UserAttack),
         
         get_Hp(BotPkm, NewHPBot),
         format('Após seu ataque, HP de ~w: ~w~n', [BotPkm, NewHPBot]),
         flush_output(user_output),
         ( NewHPBot =< 0 ->
             Winner = UserPkm,
             !
         ;
             % Turno do Bot: escolhe um ataque aleatório de 1 a 4
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
                  !
             ;
                  % Se nenhum foi derrotado, repete o turno
                  battle_pokemon(UserPkm, BotPkm, Winner)
             )
         )
    ).


infoBtl(UsuPkmn, EnPkmn):-
    pokemon_battle(UsuPkmn, UHP, _, _, _, _, UCond),
    pokemon_battle(EnPkmn, EHP, _, _, _, _, ECond),
    
    %item('Hyper Potion', HQtd),
    %write("Chegou Aqui"),
    %item('Full Restore', FQtd),
    writeln('\n=============================='),
    format('Seu Pokemon: ~w\nCurrent HP: ~w\nCondição: ~w\n', [UsuPkmn, UHP, UCond]),
    %format('Hyper Potion: ~w\nFull Restore: ~w', [HQtd, FQtd]),
    writeln('\n=============================='),
    format('Pokémon do adversário: ~w\nCurrent HP: ~w\nCondicao: ~w', [EnPkmn, EHP, ECond]),
    writeln('\n==============================\n').



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