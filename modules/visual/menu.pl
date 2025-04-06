:- module(menu, [create_menu/0]).
:- use_module(library(pce)).
:- use_module('selection', [open_selection/0]).


%% Cria a janela principal
create_menu :-
    % Inicializa a variável global
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
