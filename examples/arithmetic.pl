% Here is Peano arithmetic
plus(z, Y, Y).
plus(s(X), Y, s(Z)) :- plus(X, Y, Z).

mul(z, X, z).
mul(s(X), Y, Z) :- mul(X, Y, T) & plus(T, Y, Z).

exp(X, z, s(z)).
exp(X, s(Y), Z) :- exp(X, Y, T) & mul(T, X, Z).

% You can try to prove that multiplication is distributive on addition A * (B + C) = A * B + A * C
% mul(A,X,Z) & plus(B,C,X) & plus(M,N,Z) & mul(A,B,M) & mul(A,C,N).
% But Prolog is not a formal prover. It will just give you instances where it works. It might be enough to convice you that this property is true though.