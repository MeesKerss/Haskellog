module Terms where

import Data.Map (Map)

type Variable = String -- A variable is just defined by its name

data Term = Var Variable | Function String [Term] -- A term is either a variable or a function (a 0-ary function being a constant)
  deriving (Eq,Ord,Show)

data Clause = Fact Term | Rule Term [Term] -- A Clause is either an axiom or a conclusion and a set of premisses

type Program = [Clause] -- A program is a set of clauses

type Query = [Term] -- A query is a set of terms, interpreted as a conjunction 

type Subst = Map Variable Term -- A substitution associates a term to a variable