:- module(menu, [create_menu/0]).
:- use_module(library(pce)).
:- dynamic selected_pokemons/1. % Variável global dinâmica

% Inicializa a lista de selecionados
:- initialization(nb_setval(selected_pokemons, [])).

% Classe toggle_button modificada
:- pce_begin_class(toggle_button, button).

variable(original_label, name, both, "Rótulo original").
variable(selected, bool, both, "Estado de seleção").

initialise(B, Label: name) :->
    send_super(B, initialise, Label, message(B, toggle_selection)),
    send(B, slot, original_label, Label),
    send(B, slot, selected, @off).

toggle_selection(B) :->
    (   get(B, selected, @on)
    ->  % Desseleciona
        send(B, slot, selected, @off),
        get(B, original_label, Orig),
        send(B, label, Orig),
        nb_getval(selected_pokemons, Current),
        delete(Current, Orig, NewList),
        nb_setval(selected_pokemons, NewList)
    ;   % Seleciona
        send(B, slot, selected, @on),
        get(B, original_label, Orig),
        atom_concat('[X] ', Orig, NewLabel),
        send(B, label, NewLabel),
        nb_getval(selected_pokemons, Current),
        append(Current, [Orig], NewList),
        nb_setval(selected_pokemons, NewList)
    ),
    format('Selecionados: ~w~n', [NewList]).
:- pce_end_class.



%% Cria a janela principal
create_menu :-
    % Inicializa a variável global
    nb_setval(selected_count, 0),
    new(Window, frame('Pokemon Prolog')),
    new(Dialog, dialog),
    new(MenuButton, button('Jogar', message(@prolog, open_selection))),
    send(Dialog, size, size(300, 100)),
    new(Box, box(345, 100)),
    send(Box, pen, 0),
    send(Dialog, append, Box),
    send(Dialog, append, MenuButton, below),
    send(Dialog, layout),
    send(Window, append, Dialog),
    send(Window, open),
    send(Window, size, size(400, 300)),
    send(Window, position, point(600, 150)).


%% Tela de seleção
open_selection :-
    % Reinicia a lista ao abrir nova seleção
    nb_setval(selected_pokemons, []),
    new(SelectionWindow, dialog('Selecione 4 Pokémons')),
    
    % Cria 12 botões
    new(B1, toggle_button('Charizard')), new(B2, toggle_button('Blastoise')),
    new(B3, toggle_button('Venusaur')), new(B4, toggle_button('Pikachu')),
    new(B5, toggle_button('Pidgeot')), new(B6, toggle_button('Butterfree')),
    new(B7, toggle_button('Alakazam')), new(B8, toggle_button('Gengar')),
    new(B9, toggle_button('Onix')), new(B10, toggle_button('Seadra')),
    new(B11, toggle_button('Hitmonlee')), new(B12, toggle_button('Cloyster')),
    
    % Organização dos botões (4 linhas de 3)
    send(SelectionWindow, append, B1),
    send(SelectionWindow, append, B2, right),
    send(SelectionWindow, append, B3, right),
    
    % Linha 2
    send(SelectionWindow, append, B4, below),
    send(SelectionWindow, append, B5, right),
    send(SelectionWindow, append, B6, right),
    
    % Linha 3
    send(SelectionWindow, append, B7, below),
    send(SelectionWindow, append, B8, right),
    send(SelectionWindow, append, B9, right),
    
    % Linha 4
    send(SelectionWindow, append, B10, below),
    send(SelectionWindow, append, B11, right),
    send(SelectionWindow, append, B12, right),
    
    % Botão de confirmação
    send(SelectionWindow, append, button('Confirmar', message(@prolog, confirm_selection)), below),
    send(SelectionWindow, open).

%% Processa a seleção
confirm_selection :-
    nb_getval(selected_pokemons, Selected),
    (   length(Selected, 4)
    -> 
        format('Pokémons selecionados: ~w~n', [Selected]),
        battle(Selected)
    ;   send(@display, inform, 'Selecione exatamente 4 Pokémons')
    ).


battle(Selected) :-
  
    % Continua no terminal
    format('~n=== BATALHA INICIADA ===~n~nTime: ~w~n~n', [Selected]),
    % Aperte Ctrl + D
    write('Selecione um ataque: '),
    write(' Ataque 1'),
    write(' Ataque 2'),
    read(Ataque),
    format('~nAtaque escolhido: ~w~n', [Ataque]).
