%-----------------------------------------------------------------------
% The try predicate tries to move down, then left
% if down fails, then right if left fails, etc.
% By reordering the rules, the direction of the
% search in the maze can be changed.
%-----------------------------------------------------------------------
% Down
try(Row, Col, ToRow, Col) :- ToRow is Row + 1.
% Left
try(Row, Col, Row, ToCol) :- ToCol is Col + 1.
% Right
try(Row, Col, Row, ToCol) :- ToCol is Col - 1.
% Up
try(Row, Col, ToRow, Col) :- ToRow is Row - 1.

%-----------------------------------------------------------------------
% The memberOf(X, L) predicate suceeds if X is a member of list L.
%-----------------------------------------------------------------------
memberOf(H, [H|_]). 
memberOf(H, [X|T]) :- X \== H, memberOf(H, T).

%-----------------------------------------------------------------------
% The visit(X, L, NL) predicate suceeds if X is not a member of List L,
% and adds X to list L creating list NL.  If X is already in the list L
% it fails.
%-----------------------------------------------------------------------
visit(H, [], [H]). 
visit(X, [H|T], [H|NL]) :- X \== H, visit(X, T, NL).

%-----------------------------------------------------------------------
% The printCell(Maze, List, Row, Col) predicate prints an individual cell 
% in the maze, if Row, Col is a
%   - barrier then print an x
%   - a corner then print a +
%   - a top or bottom boundary then print a -
%   - a side boundary then print a |
%   - in the list of visited celss, then print a *
%   - by default print a blank
%-----------------------------------------------------------------------
% Print a barrier if it is there.
printCell(Maze, _, Row, Col) :- maze(Maze, Row, Col, barrier), write('x').
% Upper left corner
printCell(_, _, 0, 0) :- write('+').
% Upper right corner
printCell(Maze, _, Row, 0) :- succ(Row2, Row), isMazeBoundary(Maze, Row2, _), write('+').
% Lower left corner
printCell(Maze, _, 0, Col) :- succ(Col2, Col), isMazeBoundary(Maze, _, Col2), write('+').
% Lower right corner
printCell(Maze, _, Row, Col) :- succ(Row2, Row) , succ(Col2, Col), isMazeBoundary(Maze, Row2, Col2), write('+').
% Right boundary
printCell(_, _, 0, _) :- write('-').
% Left boundary
printCell(Maze, _, Row, _) :- succ(Row2, Row) , isMazeBoundary(Maze, Row2, _), write('-').
% Top boundary
printCell(_, _, _, 0) :- write('|').
% Bottom boundary
printCell(Maze, _, _, Col) :- succ(Col2, Col), isMazeBoundary(Maze, _, Col2), write('|').
% Member of the list
printCell(_, L, Row, Col) :- memberOf([Row,Col], L), write('*').
% Default
printCell(_, _, _, _) :- write(' ').

%Prints a given list of printable elements H, each on a new line
printList([H|T]) :- write(H), write('\n'), printList(T).

%Used to determine hard edges of the maze for writing
%Returns true if given coordinates for the edge of the map
isMazeBoundary(Maze, R, _) :- R == 0, mazeSize(Maze, R, _).
isMazeBoundary(Maze, _, C) :- C == 0, mazeSize(Maze, _, C).
isMazeBoundary(Maze, R, C) :- mazeSize(Maze, R, C).

%Used for solving the maze
%Returns true if the space is open (not an edge or barrier)
isWalkable(Maze, R, C) :- mazeSize(Maze, RM, CM),
							 R =< RM, R >= 1, 
							 C =< CM, C >= 1,
							 not(maze(Maze, R, C, barrier)).

%These first four initialize the mazeHalp call with the larger maze dimensions
printMaze(List,Maze) :- mazeSize(Maze, R, C), succ(R, R2), succ(C, C2), printMazeHalp(Maze, List, 0, 0, R2, C2).

%"Loops" through a maze structure
%RMAX and CMAX are the maze dimensions + 1, used to reset the loop at the end of a row
%RMAX is there mostly because I didn't like it being non-symettric and only having CMAX :)
printMazeHalp(Maze, List, RMAX, CMAX, RMAX, CMAX) :- printCell(Maze, List, RMAX, CMAX).
printMazeHalp(Maze, List, R1, CMAX, RMAX, CMAX) :- printCell(Maze, List, R1, CMAX), write('\n'), 
	succ(R1, R2), 
	printMazeHalp(Maze, List, R2, 0, RMAX, CMAX).
printMazeHalp(Maze, List, R1, C1, RMAX, CMAX) :- printCell(Maze, List, R1, C1), 
	succ(C1, C2),
	printMazeHalp(Maze, List, R1, C2, RMAX, CMAX).

%Solves a maze!
%Prints the maze and the correct path if it is solveable
%Returns false if the maze is impossible to solve
solve(Maze) :- solveHalp(Maze, 0, 1, List).
solveHalp(Maze, R, C, List) :- mazeSize(Maze, R, C), printMaze(List, Maze).
solveHalp(Maze, R, C, List) :- try(R, C, R2, C2), isWalkable(Maze, R2, C2), visit([R2,C2], List, NL), solveHalp(Maze, R2, C2, NL).