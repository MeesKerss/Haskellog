module Unify where

import qualified Data.Map as Map
import Terms

applySubst :: Subst -> Term -> Term -- substitute every variable in a term with their associated value
applySubst s (Var x) =
  case Map.lookup x s of
    Nothing -> Var x
    Just t -> applySubst s t -- we propagate the substitution
applySubst s (Function name l) =
  Function name (map (applySubst s) l)

unification :: Subst -> Term -> Term -> Maybe Subst
-- return a substitution if it finds one that unify two terms under a predefined substitution.
-- ADD OCCURENCE CHECK !!! use applySubst instead of lookup sometimes ?
unification sub (Var x) (Var y) =
  if x == y then Just sub else
    case Map.lookup x sub of
      Nothing ->
        case Map.lookup y sub of
          Nothing -> Just (Map.insert x (Var y) sub)
          Just t -> Just (Map.insert x t sub)
      Just t1 ->
        case Map.lookup y sub of
          Nothing -> Just (Map.insert y t1 sub)
          Just t2 -> unification sub t1 t2
unification _ _ _= undefined



