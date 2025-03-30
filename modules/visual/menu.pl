:- module(menu, [create_menu/0]). %Can be exported declaration
:- use_module(library(pce)).

create_menu:-
    new(Window, frame('Pokemon Prolog')),
    new(Button, button('Start', message(@prolog, open_choicePk))),
    new(Dialog, dialog),
    send(Dialog, append, Button),
    send(Button, alignment, center), 
    send(Window, append, Dialog),
    send(Window, open),
    send(Window, size, size(400, 300)),
    send(Window, position, point(600, 150)).

open_choicePk :- send(@display, inform, 'Botão clicado!').