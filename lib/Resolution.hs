module Resolution where

import Unify
import Terms

resolution :: Program -> [Term] -> Subst
-- We take a list of clauses and a list of terms and see if we can make them true by constructing a proof tree from our clauses
resolution = undefined