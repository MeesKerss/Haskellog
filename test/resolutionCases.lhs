\section{Resolution fixture tests}

Each case lives under \verb|test/cases/<name>/| with \verb|program.pl|,
\verb|query.txt|, and \verb|expected.txt|.

\begin{code}
module Main where

import Control.Monad (forM_)
import Data.Char (isSpace)
import Data.List (dropWhileEnd, intercalate, sort)
import qualified Data.Map as Map
import qualified Data.Set as Set
import ProgramParser (pProgram)
import QueryParser (parseQuery)
import Resolution (resolution)
import System.FilePath ((</>))
import Terms
import Test.Hspec

casesDir :: FilePath
casesDir = "test/cases"

caseNames :: [String]
caseNames = ["01_meal", "02_ground_yes", "03_ground_no", "04_ancestor", "05_empty",
             "06_peano", "07_multi_goal", "08_multiple_solutions"]

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

renderAnswers :: Query -> [Subst] -> [String]
renderAnswers q sols
  | null sols = ["false."]
  | null vs   = ["true."]
  | otherwise = sort (map oneRow sols)
  where
    vs = sort (Set.toList (Set.unions (map varsTerm q)))
    oneRow sub = intercalate ", "
      [v ++ " = " ++ prologTerm (Map.findWithDefault (Var v) v sub) | v <- vs]

runCase :: String -> IO ()
runCase name = do
  let d = casesDir </> name
  progSrc  <- readFile (d </> "program.pl")
  qSrc     <- readFile (d </> "query.txt")
  expected <- sort . filter (not . null) . map (trim . filter (/= '\r')) . lines
                <$> readFile (d </> "expected.txt")
  case (pProgram progSrc, parseQuery (trim (head (lines qSrc)))) of
    (Left e, _)           -> expectationFailure ("program: " ++ e)
    (_, Left e)           -> expectationFailure ("query: " ++ show e)
    (Right prog, Right q) -> renderAnswers q (resolution prog q) `shouldBe` expected

main :: IO ()
main = hspec $
  describe "resolution, cases in test/cases/" $
    forM_ caseNames $ \n -> it n (runCase n)
\end{code}
