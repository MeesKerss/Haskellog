parent(alice, bob).
parent(alice, charlie).
parent(bob, diana).
parent(charlie, emma).
parent(charlie, fred).
parent(george, alice).

ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).

sibling(X, Y) :- parent(P, X), parent(P, Y).

%   ancestor(X, bob).
%   ancestor(X, emma).
%   ancestor(X, bob), ancestor(X, emma).

%   sibling(bob, charlie).
%   sibling(fred, X).