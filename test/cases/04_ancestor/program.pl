% Small transitive closure (see query.txt)
parent(a,b).
parent(b,c).
ancestor(X,Y) :- parent(X,Y).
ancestor(X,Y) :- parent(X,Z), ancestor(Z,Y).
