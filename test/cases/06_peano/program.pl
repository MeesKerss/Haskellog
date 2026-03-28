% Peano arithmetic: plus(X, Y, Z) means X + Y = Z
plus(X, z, X).
plus(X, s(Y), s(Z)) :- plus(X, Y, Z).
