% Course planner example
% Try:
%   can_take(alice, X).
%   can_take(bob, compilers).

completed(alice, prog1).
completed(alice, discrete_math).
completed(alice, data_structures).

completed(bob, prog1).

requires(prog2, prog1).
requires(algorithms, data_structures).
requires(compilers, prog2).
requires(compilers, discrete_math).

can_take(Student, Course) :- requires(Course, Need) & completed(Student, Need).
