\section{ruleParser}
\hide{
\begin{code}
module RuleParser where

import Terms
import Text.Parsec
import QueryParser

type Rule = (Conclusion, [Assumption])

type Conclusion = Term
type Assumption = Term

\end{code}
In This section we look at the parser for the rules. The rules should be fed as
as a regular text file. Here some examples for rules:
\begin{verbatim}
bigger(cat(), mouse()):-
bigger(dog(), cat()):-
bigger(horse(), dog()):-
is_bigger(A,B):- bigger(A,B)
is_bigger(A,B):- bigger(A,Z) & is_bigger(Z,B)
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
pRule :: Parsec String () Clause
pRule = do
          conc<- pConc
          sepConcAssum
          assums <- pAssums
          return $ if null assums then Fact conc else Rule conc assums
\end{code}

Where the conclusion is just parsed as a term and the assumption as a list of terms.\\
We still have to implement that the list of assumption can be empty.
\begin{code}
pConc :: Parsec String () Term
pConc = pTerm

pAssums :: Parsec String () [Term]
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
              Var . read <$> many1 anyChar

        pFunc = do
              (try $ lookAhead $ oneOf ['a'.. 'z'])
              a <- (read <$> manyTill anyChar (oneOf "("))
              b <- pTerms
              return (Fun a b)

pProgram ::  String -> Either ParseError Clause
pProgram = parse pRule "<rule>"

\end{code}
Now we add an acces:

\begin{code}


pV :: Parsec String () Term
pV = pLk <* eof where
      pLk =  Var . read <$> many1 anyChar

      --pLk = (try $ lookAhead $ oneOf ['A'.. 'Z']) >> Var . read <$> many1 anyChar
pProgram ::  String -> Either ParseError Clause
pProgram = parse pRule "<rule>"


\end{code}


