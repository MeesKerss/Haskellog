This module is about the resolution algorithm

\begin{code}
module Resolution where

import Unify
import Terms

resolution :: Program -> Query -> Subst
-- We take a list of clauses and a list of terms and see if we can make them true by constructing a proof tree from our clauses
resolution = undefined

\end{code}