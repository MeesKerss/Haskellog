% Family tree example (facts + recursive rule)
% Try:
%   ancestor(alice, Y).
%   ancestor(X, diana).
%   sibling(charlie, dana).
%   sibling(X, Y).

parent(alice, bob).
parent(alice, charlie).
parent(bob, diana).
parent(charlie, emma).
parent(charlie, fred).
parent(george, alice).

ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z) & ancestor(Z, Y).

sibling(X, Y) :- parent(P, X) & parent(P, Y).
