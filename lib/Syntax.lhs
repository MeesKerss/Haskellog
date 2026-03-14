\begin{code}

module Syntax where

data Term = Var String | Struct String [Term]
  deriving (Show, Eq)

data Clause = Fact Term | Rule Term [Term]
  deriving (Show, Eq)

type Program = [Clause]


\end{code}