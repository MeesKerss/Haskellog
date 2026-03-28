\section{ruleParser}
\hide{
\begin{code}
import Text.Read (readMaybe)
import Text.Parsec

type Rule = (Conclusion, [Assumption])

type Conclusion = Term
type Assumption = Term

data Term =  V Variable | Fun Func [Term]
  deriving (Eq,Ord,Show)

type Func = String
type Variable = String
\end{code}}
In This section we look at the parser for the rules. The rules should be fed as
as a regular text file. Here some examples for rules:
\begin{verbatim}
bigger(cat(), mouse()):-.
bigger(dog(), cat()):-.
bigger(horse(), dog()):-.
is_bigger(A,B):- bigger(A,B).
is_bigger(A,B):- bigger(A,Z) & is_bigger(Z,B).
\end{verbatim}
We interpret constants as 0-ary functions. The ":-" can be read as 
"if". We only allow horn-clauses so the only connector is conjunction for now.
\\We use Parsec for the parsing. Now to parse the rules we first establish some seperators:

\begin{code}
sepConcAssum :: Parsec String () ()
sepConcAssum = do
                spaces
                string ":-"
                spaces

andSep :: Parsec String () ()
andSep = do
          spaces 
          char '&'
          spaces

termSep :: Parsec String () ()
termSep = do
          spaces 
          char ','
          spaces

endOfList :: Parsec String () ()
endOfList = do
          spaces 
          char ')'
          spaces
\end{code}
Now every Rule is a conclusion and a list of assumptions. We first seperate the clause
in its two parts:
\begin{code}
pRule :: Parsec String () Rule
pRule = do
          conc<- pConc
          sepConcAssum
          assums <- pAssums
          return (conc, assums)
\end{code}
Where the conclusion is just parsed as a term and the assumption as a list of terms.\\
We still have to implement that the list of assumption can be empty.
\begin{code}
pConc :: Parsec String () Conclusion
pConc = pTerm
 
pAssums :: Parsec String () [Assumption]
pAssums = many $ do
    assum <- pTerm
    eof <|> andSep
    return assum
\end{code}

We allready made it possible in for the list of terms in a funciton to be empty.
\begin{code}
pTerms :: Parsec String () [Term]
pTerms = list <|> emptyList where
    emptyList = spaces >> char ')' >> return []
    list = many $ do
      assum <- pTerm
      endOfList <|> termSep
      return assum
\end{code}

Note that the "try lookAhead" is checking the next character without "devouring it".
So we can check if the first letter is capatalized or not. This is our convention for funcitons vs variable.
\begin{code}
pTerm :: Parsec String () Term
pTerm = pVar <|> pFunc where
        pVar = do
              (try $ lookAhead $ oneOf ['A'.. 'Z'])
              V . read <$> many1 anyChar
        pFunc = do
              (try $ lookAhead $ oneOf ['a'.. 'z'])
              a <- (read <$> manyTill anyChar (oneOf " ("))
              b <- pTerms
              return (Fun a b)
\end{code}
What is still left to do is to check for spaces at the right places.
