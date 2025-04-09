:- module(logger, [log_message/2, init_logger/0]).
:- use_module(library(pce)).

:- dynamic log_editor/1.

init_logger :-
    new(Frame, frame('Log da Batalha')),
    new(Dialog, dialog),
    send(Frame, append, Dialog),
    
    new(Editor, editor),
    send(Editor, size, size(80, 20)),
    send(Dialog, append, Editor),
    
    send(Frame, open),
    
    retractall(log_editor(_)),
    assertz(log_editor(Editor)).

log_message(Format, Args) :-
    format(string(Message), Format, Args),
    log_editor(Editor),
    send(Editor, append, Message),
    send(Editor, append, '\n').
