This module is about the resolution algorithm

\begin{code}
module Resolution where

import Unify
import Terms
import Control.Monad.State
import qualified Data.Map as Map
import qualified Data.Set as Set
import Data.List (nub)
import Data.Maybe (catMaybes)

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

\verb|solveOneClause| is one step of the SLD resolution algorithm, we take the current state of our substitution, one clause of the program which we will replace variables by fresh ones, one goal of the query, the rest of the query and we try to unify the term with the clause. If we suceed, we return the substitution that worked as well as the queries that still need to be computed. solveGoal give a list of the substitutions coming from successful unifications with clauses of our program.

\begin{code}

solveOneClause :: Subst -> Clause -> Term -> Query -> State Int (Maybe (Subst, Query))
solveOneClause initSub clause goal restQuery =
  do
    clause' <- freshenClause clause
    case unification initSub goal (headClause clause') of
      Nothing -> pure Nothing
      Just sub ->
        let query = applySubstQuery sub (bodyClause clause' ++ restQuery) in
        pure (Just (sub, query))

solveGoal :: Subst -> Program -> Term -> Query -> State Int [ (Subst, Query) ]
solveGoal initSub prog goal restQuery = do
  fmap catMaybes (mapM (\clause -> solveOneClause initSub clause goal restQuery) prog)

\end{code} 

This is the main algorithm performing SLD resolution. In entry we take our programs which is a list of clauses, a substitution which should be empty as first but will be useful for recursive calls, as well as a list of our goal, the program should output a (possibly infinite) list of substitutions of the variables such that the conjonctive query is made true. The idea is just to aly recursively the step we defined earlier.

\begin{code}

resolve :: Subst -> Program -> Query -> State Int [Subst]
resolve sub _ [] = pure [sub]
resolve currentSub prog (goal:restGoals) = do
  nextSteps <- solveGoal currentSub prog goal restGoals
  concat <$> mapM (\(sub', query') -> resolve sub' prog query') nextSteps

\end{code}

We now define the clean resolution, hiding the mechanism using the state mmonad or the explicit "current substitution" in argument. We just start the resolve programm with an empty substitution and with the state 0. We also remove all the internal variables from the computation and normalize them by aplying the substitution as far as we can (to get X = bob Y = bob instead of X=Y Y=bob for example).

\begin{code}

resolution :: Program -> Query -> [Subst]
resolution prog query =
  let solutions = evalState (resolve Map.empty prog query) 0
  in nub (map (restrictSubst query) solutions)

restrictSubst :: Query -> Subst -> Subst
restrictSubst query sub =
  let vars = Set.unions (map varsTerm query) -- all the variables in our query
  in Map.fromList
       [ (x, applySubst sub t) -- we do the normalization here by alying applySubst
       | (x, t) <- Map.toList sub
       , x `Set.member` vars -- we only keep variables that are in the input query
       ]

\end{code}

An example to test the algo before we linked everything together. It shouldn't be here in the end ! TODO

\begin{code}

prog1 :: Program
prog1 =
  [ Fact (Fun "parent" [Fun "bob" [], Fun "alice" []])
  , Fact (Fun "parent" [Fun "alice" [], Fun "charlie" []])
  , Fact (Fun "parent" [Fun "charlie" [], Fun "diana" []])

  , Rule (Fun "ancestor" [Var "X", Var "Y"])
         [Fun "parent" [Var "X", Var "Y"]]

  , Rule (Fun "ancestor" [Var "X", Var "Y"])
         [ Fun "parent" [Var "X", Var "Z"]
         , Fun "ancestor" [Var "Z", Var "Y"]
         ]
  ]

query1 :: Query
query1 =
  [Fun "ancestor" [Fun "bob" [], Var "Y"]]

query2 :: Query -- test for two queries
query2 =
  [ Fun "ancestor" [Fun "bob" [], Var "Y"]
  , Fun "ancestor" [Var "Y", Fun "diana" []]
  ]

query3 :: Query --true but no variables -> empty substitution
query3 =
  [Fun "ancestor" [Fun "bob" [], Fun "diana" []]]

query4 :: Query --false = empty list
query4 =
  [Fun "ancestor" [Fun "alice" [], Fun "bob" []]]

query5 :: Query --list all pairs ancestor/decendant
query5 =
  [Fun "ancestor" [Var "X", Var "Y"]]

\end{code}

TODO :
if we give the rule parent(X,X) and ask parent(Y,Y), we get  Y = X_0. It is correct, indeed Y should just be instanciated as any variable but maybe we could make it cleaner by either say "Y=Y" or just outut "yes" if it is true for any variables (we just show the variables that need a secific instanciation). -> aybe it should be treated on the UI/pretty printing side.

Be careful for the retty printing/UI part to use lazyness, we could maybe get a possible infinite amount of solutions so the [Subst] given by resolution could be infinite, we have to print them one by one and only make the program do the calculations that are needed (maybe with a buffer so we don't always redo all the calculations ?)