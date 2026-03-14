\section{Wrapping it up in an executable}\label{sec:Main}

The entry point reads every file given on the command line, concatenates their
contents, and hands the result to the interactive REPL.

\begin{verbatim}
stack build
stack exec myprogram -- facts.pl rules.pl
\end{verbatim}

If no files are given the REPL starts with an empty clause pane.

\begin{code}
module Main where

import Tui (runTui)
import System.Environment (getArgs)

main :: IO ()
main = do
  files    <- getArgs
  contents <- mapM readFile files
  runTui (unlines contents)
\end{code}
