module Terms where

data Term = Var String | Function String [Term]

data Clause = Fact Term | Rule Term [Term]

type Program = [Clause]