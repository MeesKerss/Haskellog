# rules test file

derive equals(z,z).

derive equals(s(X),s(Y))
    from equals(X,Y).


derive plus(z,Y,Y).

derive plus(s(X),Y,s(Z))
  from plus(X,Y,Z).


derive mult(z,X,z).

derive mult(s(X),Y,Z)
    from mult(X,Y,W), plus(W,Y,Z).


derive exp(X,z,s(z)).

derive exp(z,X,z).

derive exp(X,s(Y),Z)
    from exp(X,Y,W),mult(W,X,Z).






derive true(t).

derive false(f).

derive not(X)
    from false(X).

derive and(A,B)
    from true(A),true(B).

derive xor(A,B)
    from true(A),false(B).

derive xor(A,B)
    from false(A),true(B).


derive or(A,B)
    from true(A).

derive or(A,B)
    from true(B).
