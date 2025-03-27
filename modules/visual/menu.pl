:- module(menu, [create_menu/0]). %Can be exported declaration
:- use_module(library(pce)).

create_menu:-
    new(Window, frame('Pokemon Prolog')),
    new(Button, button('Start'), message(@prolog, open_choicePk)),
    new(Dialog, dialog),
    send(Dialog, append, Button),
    send(Window, append, Dialog),
    send(Window, open).

open_choicePk :- send(@display, inform, 'Botão clicado!').