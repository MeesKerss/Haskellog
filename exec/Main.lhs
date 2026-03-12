
\section{Wrapping it up in an exectuable}\label{sec:Main}

We will now use the library form Section \ref{sec:Basics} in a program.

\begin{code}
module Main where

import Basics

main :: IO ()
main = do
  putStrLn "Hello!"
  print somenumbers
  print (map funnyfunction somenumbers)
  myrandomnumbers <- randomnumbers
  print myrandomnumbers
  print (map funnyfunction myrandomnumbers)
  putStrLn "GoodBye"
\end{code}

We can run this program with the commands:

\begin{verbatim}
stack build
stack exec myprogram
\end{verbatim}

The output of the program is something like this:

\begin{verbatim}
Hello!
[1,2,3,4,5,6,7,8,9,10]
[100,100,300,300,500,500,700,700,900,900]
[1,3,0,1,1,2,8,0,6,4]
[100,300,42,100,100,100,700,42,500,300]
GoodBye
\end{verbatim}

% I begin the code that I wrote here so you guys can still look up the example malvin gave for literate programming
Here we define some basic types that we will need for our project. 
\begin{code}
type Rule = (Conclusions, [Assumptions])

type Conclusions = Term
type Assumptions = Term
data Term =  V Variable | T Func [Term]
  deriving (Eq,Ord,Show)

type Func = String
type Variable = Int
\end{code}
