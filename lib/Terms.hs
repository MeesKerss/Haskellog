module Terms where

data Term = Var String | Function String [Term] -- A term is either a variable or a function (a 0-ary function being a constant)

data Clause = Fact Term | Rule Term [Term] -- A Clause is either an axiom or a conclusion and a set of premisses

type Program = [Clause] -- A program is a set of clauses

type Query = [Term] -- A query is a set of terms, interpreted as a conjunction 