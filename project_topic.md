---
title: An Haskell interpreter for Prolog
author: Nicolas Dassas-Henny, Mees Kerssens, Dionysis Yusofy (Group 2)
date: 
---

*Acknowledgement: This project is inspired by an OCaml exam by David Baelde for the ENS Rennes bachelor’s programming course.*

## Goal

This project aim to developp an interpreter for a prolog-like language. It should be able to take as input a file consisting of Horn clauses (a disjunction of literals with at most one positive), representing axioms (just a single positive litteral) or inference rules (the conclusion being the positive litteral and the atom of the negative litterals the premisses).
When running the program should then accept queries (a list of atoms interpreted as conjunction) from user and answer no if these queries are not satisfiable or yes otherwise, if there is variables it should also give an instanciation of those variables to make the rule true (and continue running to find more instanciation if asked by the user to do so).

The atoms for queries and rules should have variables and functions (with constants being functions of arity 0).

For example rules could be

```
derive plus(z,Y,Y).

derive plus(s(X),Y,s(Z))
  from plus(X,Y,Z).
```
  
and an execution of the program could be
```
Query ?
	plus(X,Y,Y)
yes: X = z More solutions ? [y/N]
	N
Query ?
	plus(X,Y,Z)
yes: X = z, Y = Z More solutions ? [y/N]
	y
yes: X = s(z), Y = s(Z) More solutions ? [y/N]
	n
Query ?
	plus(X,0,Y), plus(X,0,s(Y))
no
Query ?
	min(X,z) = z
no
```

## What will need to be done

- use of a parser to parse the rules and queries
- implementation of a way to [\underline{unify}](https://en.wikipedia.org/wiki/Unification_(computer_science) "unification - wikipedia") two terms 
- implementation of an [\underline{algorithm}](https://en.wikipedia.org/wiki/SLD_resolution "something like that") to find solve a conjunction of queries using unification, depth-first search and backtracking
- miscellaneous details : pretty printing, syntax sugar for integer, possible optimizations...
