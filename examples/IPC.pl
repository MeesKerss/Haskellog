implies(X, implies(Y,X)):-.
implies(X, implies(implies(Y,Z),implies(implies(X,Y),implies(X,Z)))):-.
implies(X, implies(Y,and(X,Y))):-.
implies(and(X,Y), X):-.
implies(and(X,Y), Y):-.
implies(X, or(X,Y)):-.
implies(Y, or(X,Y)):-.
implies(implies(X,Z),implies(implies(Y,Z),implies(or(X,Y),Z))):-.
implies(f,X).
Y:-implies(X,Y)& X.
