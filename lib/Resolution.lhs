This module is about the resolution algorithm

\begin{code}
module Resolution where

import Unify
import Terms
import Control.Monad.State
import qualified Data.Map as Map
import qualified Data.Set as Set

\end{code}
We will need in our algorithm to rename some variables to fresh one because the application of a rule is supposed to be local, Haskellog might apply the same rule twice but on different variables. For that we use the state monad incrementing an integer each time we want to reuse a variable (we first use the variable X1 then X2...).

\begin{code}

freshVarName :: Variable -> State Int Variable -- From X return State X_n (n+1) with n the internal state of the monad
freshVarName x = do
  n <- get
  put (n + 1)
  return (x ++ "_" ++ show n)

buildRenaming :: Set.Set Variable -> State Int (Map.Map Variable Variable) -- take a set of Variables and return a renaming associating them to fresh variables
buildRenaming vars = do
  pairs <- mapM freshPair (Set.toList vars)
  return (Map.fromList pairs)
  where
    freshPair x = do
      y <- freshVarName x
      return (x, y)

renameTerm :: Map.Map String String -> Term -> Term -- take a renaming and apply it to a term
renameTerm env (Var x) =
  case Map.lookup x env of
    Just y  -> Var y
    Nothing -> Var x
renameTerm env (Fun f args) =
  Fun f (map (renameTerm env) args)

renameClause :: Map.Map String String -> Clause -> Clause -- apply the renaming of terms inside a clause
renameClause env (Fact t) =
  Fact (renameTerm env t)
renameClause env (Rule h body) =
  Rule (renameTerm env h) (map (renameTerm env) body)

freshenClause :: Clause -> State Int Clause -- we can now write "do clause' <- freshenClause clause" to get a clause with fresh variable in clause'
freshenClause clause = do
  let vars = varsClause clause
  env <- buildRenaming vars
  return (renameClause env clause)

\end{code}

\verb|solveOneClause| is one step of the SLD resolution algorithm, we take one clause of the program, one goal of the query, the rest of the query and we try to unify the term with the clause. If we suceed, we return the substitution that worked as well as the queries that still need to be computed.

\begin{code}

solveOneClause :: Clause -> Term -> [Term] -> State Int (Maybe (Subst, Query))
solveOneClause clause goal restQuery =
  case unification Map.empty goal (headClause clause) of
    Nothing -> pure Nothing
    Just sub ->
      let query = applySubstQuery sub (bodyClause clause ++ restQuery) in
      pure (Just (sub, query))

\end{code} 

This is the main algorithm, it works as follow. In entry we take our programs, a list of clauses as well as a list of our goal, the program should output a (possibly infinite) list of substitutions of the variables such that the conjonctive query is made true.

\begin{code}

resolution :: Program -> Query -> Maybe [Subst]
-- We take a list of clauses and a list of goals and see if we can make them true by constructing a proof tree from our clauses
resolution [] _ = Nothing
resolution _ [] = Just [Map.empty]
resolution (rule:otherRules) (query:otherQueries) = undefined

\end{code}