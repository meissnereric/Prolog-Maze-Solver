:- dynamic user:file_search_path/2.
:- multifile user:file_search_path/2.
user:file_search_path('prologMazeSolver', '/home/eric/dev/prologmazesolver').

:- consult('prologMazeSolver'('../prologmazesolver/test.pl')).
