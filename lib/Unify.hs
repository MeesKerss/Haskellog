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

occurrenceCheck :: String -> Term -> Bool -- check if the name of a variable appears in a term
occurrenceCheck x (Var y) = x == y
occurrenceCheck x (Fun _ l) = any (occurrenceCheck x) l

unification :: Subst -> Term -> Term -> Maybe Subst
-- return a substitution if it finds one that unify two terms under a predefined substitution.
unification sub t1 t2 =
  case (applySubst sub t1, applySubst sub t2) of
    (Var x, Var y) ->
      if x == y then Just sub else Just (Map.insert x (Var y) sub)
    (Var x, fun) ->
      if occurrenceCheck x fun then Nothing else -- The variable appears in the function
        Just (Map.insert x fun sub)
    (fun, Var y) ->
      if occurrenceCheck y fun then Nothing else -- The variable appears in the function
        Just (Map.insert y fun sub)
    (Fun name1 l1, Fun name2 l2)
      | name1 /= name2 -> Nothing
      | otherwise -> unifyLists sub l1 l2

unifyLists :: Subst -> [Term] -> [Term] -> Maybe Subst
unifyLists sub [] [] = Just sub
unifyLists sub (x1:xs1) (x2:xs2) =
  unification sub x1 x2 >>= (\ s -> unifyLists s xs1 xs2)
unifyLists _ _ _ = Nothing
