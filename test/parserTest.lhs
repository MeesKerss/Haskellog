\subsection{Parsers tests}

We use the \texttt{Arbitrary} instances from \texttt{Terms} to generate random programs and
check that the pretty-printer and parser are inverses of each other.

\begin{code}
module Main where

import Test.Hspec
import Test.QuickCheck
import Terms
import ProgramParser (pProgram)
import QueryParser (parseQuery)

main :: IO ()
main = hspec $ do
  describe "ProgramParser" $
    it "parsed result contains all original clauses" $ property $
      \prog -> counterexample (prologProgram prog) $
        case pProgram (prologProgram prog) of
          Left err  -> counterexample err False
          Right got -> property $ all (`elem` got) prog
  describe "QueryParser" $
    it "parses any generated term without crashing" $ property $
      \t -> counterexample (prologTerm t) $
        case parseQuery (prologTerm t) of
          Left err -> counterexample (show err) False
          Right _  -> property True
\end{code}
