:- module(battle_system, [battle/2]).
:- use_module('pokemon').  % Certifique-se de que o módulo de lógica dos pokémons esteja disponível

% Predicado auxiliar para extrair o Pokémon ativo (head) de um time.
active_pokemon([pokemon_battle(Name,_,_,_,_,_,_)|Rest], Name, Rest).

%% battle(+TimeUsuario, +TimeBot)
%
% Recebe duas listas de Pokémon (no formato battle) e realiza
% a batalha enquanto ambos os times possuírem pelo menos um Pokémon.
%
battle(TimeUser, TimeBot) :-
    format('~n=== BATALHA INICIADA ===~n~nTime: ~w~n~n'),
    battle_system(TimeUser, TimeBot).

battle_system(TeamUser, TeamBot) :-
    % Condição de término: se algum time estiver vazio, a batalha acaba.
    ( TeamUser = [] ->
         format('Você perdeu a batalha!~n'),
         flush_output(user_output)
    ; TeamBot = [] ->
         format('Você venceu a batalha!~n'),
         flush_output(user_output)
    ;
         % Pega os Pokémon ativos (head) de cada time
         active_pokemon(TeamUser, UserPkm, RestUser),
         active_pokemon(TeamBot, BotPkm, RestBot),
         format('Iniciando duelo entre ~w e ~w~n', [UserPkm, BotPkm]),
         flush_output(user_output),
         battle_pokemon(UserPkm, BotPkm, Winner),
         ( Winner = BotPkm ->
             format('Seu Pokémon ~w morreu!~n', [UserPkm]),
             flush_output(user_output),
             % Remove o Pokémon do usuário; time do bot permanece
             NewTeamUser = RestUser,
             NewTeamBot = TeamBot
         ; Winner = UserPkm ->
             format('O Pokémon do Bot ~w morreu!~n', [BotPkm]),
             flush_output(user_output),
             % Remove o Pokémon do bot; time do usuário permanece
             NewTeamUser = TeamUser,
             NewTeamBot = RestBot
         ),
         % Prossegue para a próxima rodada
         battle_system(NewTeamUser, NewTeamBot)
    ).

%% battle_pokemon(+UserPkm, +BotPkm, -Winner)
%
% Realiza os turnos de ataque entre os dois Pokémon ativos. O bot
% sempre ataca primeiro. Após cada ataque, verifica se algum dos dois
% Pokémon foi derrotado (HP <= 0) e, caso contrário, repete o turno.
%
battle_pokemon(UserPkm, BotPkm, Winner) :-
    % Obtém o HP atual dos Pokémon
    get_Hp(UserPkm, HPUser),
    get_Hp(BotPkm, HPBot),
    ( HPUser =< 0 ->
         Winner = BotPkm, !
    ; HPBot =< 0 ->
         Winner = UserPkm, !
    ;
         % Turno do Bot: escolhe um ataque aleatório de 1 a 4
         format('Bot ~w ataca primeiro!~n', [BotPkm]),
         flush_output(user_output),
         random_between(1, 4, BotAttack),
         realiza_ataque(BotPkm, UserPkm, BotAttack),
         get_Hp(UserPkm, NewHPUser),
         format('Após o ataque do Bot, HP de ~w: ~w~n', [UserPkm, NewHPUser]),
         flush_output(user_output),
         ( NewHPUser =< 0 ->
             Winner = BotPkm, !
         ;
             % Turno do Usuário: prompt para escolha do ataque (1 a 4)
             write('Escolha seu ataque (1-4): '),
             flush_output(user_output),
             read(UserAttack),
             realiza_ataque(UserPkm, BotPkm, UserAttack),
             get_Hp(BotPkm, NewHPBot),
             format('Após seu ataque, HP de ~w: ~w~n', [BotPkm, NewHPBot]),
             flush_output(user_output),
             ( NewHPBot =< 0 ->
                  Winner = UserPkm, !
             ;
                  % Se nenhum foi derrotado, o turno se repete
                  battle_pokemon(UserPkm, BotPkm, Winner)
             )
         )
    ).
