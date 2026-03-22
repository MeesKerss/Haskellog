\section{Random Generators}
\label{sec:generators}

QuickCheck generators for our data types.

\begin{code}
module Generators where

import Test.QuickCheck hiding (Fun)
import Control.Monad (replicateM)
import Terms

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
