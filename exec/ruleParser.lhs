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


pRule :: Parsec String () Rule
pRule = do
          conc<- pConc
          sepConcAssum
          assums <- pAssums
          return (conc, assums)

pConc :: Parsec String () Conclusion
pConc = pTerm

pAssums :: Parsec String () [Assumption]
pAssums = many $ do
    assum <- pTerm
    eof <|> andSep
    return assum

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

pTerms :: Parsec String () [Term]
pTerms = list <|> emptyList where
    emptyList = spaces >> char ')' >> return []
    list = many $ do
      assum <- pTerm
      endOfList <|> termSep
      return assum
\end{code}