:- module(historico, 
    [iniciar_placar/0,
     incrementa_vitoria/0,
     incrementa_derrota/0,
     get_estatisticas/1]).

:- use_module(library(csv)).
:- dynamic placar/2.  % placar(Partidas, Vitorias)

% Arquivo CSV (apenas 2 números: Partidas,Vitorias)
arquivo_placar('placar.csv').

% Inicialização do placar
iniciar_placar :-
    (   existe_placar
    ->  carregar_placar
    ;   criar_placar
    ).

% Verifica se o arquivo existe e é válido
existe_placar :-
    arquivo_placar(File),
    exists_file(File),
    csv_read_file(File, [row(P, V)]),
    number(P), number(V).

% Carrega os valores do arquivo
carregar_placar :-
    arquivo_placar(File),
    csv_read_file(File, [row(P, V)]),
    retractall(placar(_, _)),
    assertz(placar(P, V)).

% Cria novo arquivo com valores zerados
criar_placar :-
    retractall(placar(_, _)),
    assertz(placar(0, 0)),
    salvar_placar.

% Salva os valores atuais no CSV
salvar_placar :-
    arquivo_placar(File),
    placar(P, V),
    setup_call_cleanup(
        open(File, write, Stream),
        csv_write_stream(Stream, [row(P, V)], []),
        close(Stream)
    ).

% Incrementa uma vitória
incrementa_vitoria :-
    retract(placar(P, V)),
    NovoP is P + 1,
    NovoV is V + 1,
    assertz(placar(NovoP, NovoV)),
    salvar_placar.

% Incrementa uma derrota
incrementa_derrota :-
    retract(placar(P, V)),
    NovoP is P + 1,
    assertz(placar(NovoP, V)),
    salvar_placar.

% Mostra estatísticas formatadas
get_estatisticas(Estatisticas) :-
    placar(P, V),
    format(atom(Estatisticas),
        'Partidas jogadas: ~d\nNúmero de vitórias: ~d', 
        [P, V]).