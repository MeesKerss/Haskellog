module Unify where

import qualified Data.Map as Map
import Terms

applySubst :: Subst -> Term -> Term -- substitute every variable in a term with their associated value
applySubst s (Var x) =
  case Map.lookup x s of
    Nothing -> Var x
    Just t -> applySubst s t -- we propagate the substitution
applySubst s (Fun name l) =
  Fun name (map (applySubst s) l)

occurenceCheck :: String -> Term -> Bool -- check if the name of a variable appears in a term
occurenceCheck x (Var y) = x == y
occurenceCheck x (Fun _ l) = any (occurenceCheck x) l

unification :: Subst -> Term -> Term -> Maybe Subst
-- return a substitution if it finds one that unify two terms under a predefined substitution.
-- ADD OCCURENCE CHECK !!! use applySubst instead of lookup sometimes ?
unification sub t1 t2 =
  case (applySubst sub t1, applySubst sub t2) of
    (Var x, Var y) ->
      if x == y then Just sub else Just (Map.insert x (Var y) sub)
    (Var x, Fun name l) -> undefined


