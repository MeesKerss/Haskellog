ack(z,X,s(X)).
ack(s(X),z,Y):-ack(X,s(z),Y).
ack(s(X),s(Y),Z):-ack(s(X),Y,R), ack(X,R,Z).