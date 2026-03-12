module Resolution where

import Unify
import Terms

resolution :: Program -> [Term] -> IO ()
-- We take a list of clauses and a list of terms and see if we can make them true
resolution = undefined