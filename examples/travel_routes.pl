% Route planning example (transitive closure)
% Try:
%   route(amsterdam, X).
%   route(X, berlin).
%   route(paris, berlin).
%   route(berlin, paris).

direct(amsterdam, brussels).
direct(brussels, paris).
direct(paris, lyon).
direct(lyon, milan).
direct(milan, zurich).
direct(zurich, berlin).

route(X, Y) :- direct(X, Y).
route(X, Y) :- direct(X, Z), route(Z, Y).
