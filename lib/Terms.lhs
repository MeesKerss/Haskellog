\section{Basic Types}
This module defines our basic types as well as some basic operations on them.

\begin{code}
module Terms where

import Test.QuickCheck hiding (Fun)
import Control.Monad (replicateM)
import Data.Map (Map)
import qualified Data.Set as Set
import Data.List (intercalate)

type Variable = String -- A variable is just defined by its name

data Term = Var Variable | Fun String [Term] -- A term is either a variable or a function (a 0-ary function being a constant)
  deriving (Eq,Ord,Show)

data Clause = Fact Term | Rule Term [Term] -- A Clause is either an axiom or a conclusion and a set of premisses
  deriving (Eq,Ord,Show)

type Program = [Clause] -- A program is a set of clauses

type Query = [Term] -- A query is a set of terms, interpreted as a conjunction

type Subst = Map Variable Term -- A substitution associates a term to a variable

varsTerm :: Term -> Set.Set Variable -- output a set of all variables in a term. Usefull for renaming them to fresh variables.
varsTerm (Var x) = Set.singleton x
varsTerm (Fun _ l) = Set.unions (map varsTerm l)

varsClause :: Clause -> Set.Set Variable -- idem for clauses
varsClause (Fact t) = varsTerm t
varsClause (Rule t l) = Set.unions (varsTerm t : map varsTerm l)

headClause :: Clause -> Term -- Fact/Conclusion
headClause (Fact t) = t
headClause (Rule t _) = t

bodyClause :: Clause -> [Term] -- Premises
bodyClause (Fact _) = []
bodyClause (Rule _ l) = l

\end{code}

\section{Prolog Pretty Printer}
These functions render our data structures as valid Prolog source text.

\begin{code}

-- | Render a 'Term' in Prolog notation.
prologTerm :: Term -> String
prologTerm (Var x)       = x
prologTerm (Fun name []) = name
prologTerm (Fun name args) =
  name ++ "(" ++ intercalate "," (map prologTerm args) ++ ")"

-- | Render a 'Clause' (facts end with *.*, rules use *:-*).
prologClause :: Clause -> String
prologClause (Fact t)      = prologTerm t ++ "."
prologClause (Rule h body) =
  prologTerm h ++ " :-\n    " ++
  intercalate " &\n    " (map prologTerm body) ++ "."

-- | Render a 'Program' as a Prolog source file.
prologProgram :: Program -> String
prologProgram = unlines . map prologClause

-- | Render a 'Query' in *?-* directive style.
prologQuery :: Query -> String
prologQuery []  = "?- true."
prologQuery ts  = "?- " ++ intercalate ", " (map prologTerm ts) ++ "."


\end{code}

The following code defines \texttt{Arbitrary} instances and generators for random \texttt{Term}s and \texttt{Clause}s.
Originally, the intention was to use these with QuickCheck to test Haskellog against an existing Prolog interpreter written in Haskell.
Unfortunately this turned out not to be feasible: the only available package did not support our version of GHC.
Instead, we use the generators to verify that our parsers are correct: a randomly generated program is pretty-printed and parsed back,
and we check that the result contains the original clauses (see Section on parser tests).

\begin{code}


genVar :: Gen Term
genVar = Var <$> elements ["X","Y","Z","W"]

genFunName :: Gen String
genFunName = elements ["a","b","c","f","g","h"]

genTerm :: Int -> Gen Term
genTerm 0 = oneof [genVar, Fun <$> genFunName <*> pure []]
genTerm n = oneof
  [ genVar
  , do name  <- genFunName
       arity <- choose (0, 3)
       args  <- replicateM arity (genTerm (n `div` 2))
       return (Fun name args)
  ]

instance Arbitrary Term where
  arbitrary = sized genTerm
  shrink (Var _)      = []
  shrink (Fun f args) = args ++ [Fun f as | as <- shrinkList shrink args]

instance Arbitrary Clause where
  arbitrary = oneof
    [ Fact <$> arbitrary
    , Rule <$> arbitrary <*> resize 3 (listOf1 arbitrary)
    ]
  shrink (Fact t)    = Fact <$> shrink t
  shrink (Rule h bs) = [Fact h]
                    ++ [Rule h' bs | h' <- shrink h]
                    ++ [Rule h bs' | bs' <- shrinkList shrink bs, not (null bs')]

\end{code}