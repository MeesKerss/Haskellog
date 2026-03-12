module Unify where

import qualified Data.Map as Map
import Terms

applySubst :: Subst -> Term -> Term
applySubst s (Var x) =
  case Map.lookup x s of
    Nothing -> Var x
    Just t -> applySubst s t -- we propagate the substitution
applySubst s (Function name l) =
  Function name (map (applySubst s) l)
