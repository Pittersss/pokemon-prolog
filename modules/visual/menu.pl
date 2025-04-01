:- module(menu, [create_menu/0]).
:- use_module(library(pce)).

create_menu :-
    new(Window, frame('Pokemon Prolog')),
    new(Dialog, dialog),
    new(Button, button('Jogar', message(@prolog, open_choicePk, Window))),
    send(Dialog, size, size(300, 100)),  
    new(Box, box(345, 100)), 
    send(Box, pen, 0),
    send(Dialog, append, Box),
    send(Dialog, append, Button, below),
    send(Dialog, layout),
    send(Window, append, Dialog),
    send(Window, open),
    send(Window, size, size(400, 300)),
    send(Window, position, point(600, 150)).

open_choicePk(OldWindow) :-
    send(OldWindow, destroy),
    new(NewWindow, frame('Escolha seu Pokémon')),
    send(NewWindow, open),
    send(NewWindow, size, size(400, 300)),
    send(NewWindow, position, point(600, 150)).
