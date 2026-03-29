\subsection{Query Parser}

When the user submits a query in the TUI text box, it is parsed by this module before being passed to the resolution engine.
It is implemented with Parsec and accepts the same term syntax as the rule parser.
The \verb|?-| prefix and trailing \verb|.| are optional, so both Prolog-style and bare queries are accepted.
Conjunction (\verb|&|) and disjunction (\verb$|$) are supported, with conjunction binding more tightly.

\begin{code}
module QueryParser (Query, parseQuery) where

import Text.Parsec
import Text.Parsec.String (Parser)
import Terms

ws :: Parser ()
ws = spaces

lexeme :: Parser a -> Parser a
lexeme p = p <* ws

sym :: String -> Parser String
sym s = lexeme (string s)

pVar :: Parser Term
pVar = lexeme $ do
  first <- upper <|> char '_'
  rest  <- many (alphaNum <|> char '_')
  return $ Var (first : rest)

pAtom :: Parser Term
pAtom = lexeme $ do
  first <- lower
  rest  <- many (alphaNum <|> char '_')
  return $ Fun (first : rest) []

pStruct :: Parser Term
pStruct = lexeme $ do
  first <- lower
  rest  <- many (alphaNum <|> char '_')
  let name = first : rest
  args <- between (sym "(") (sym ")") (pTerm `sepBy` sym ",")
  return $ Fun name args

pTerm :: Parser Term
pTerm = try pStruct <|> try pVar <|> pAtom

pQuery :: Parser Query
pQuery = do
  ws
  optional (try (sym "?-"))
  expr <- pOr
  optional (sym ".")
  eof
  return [expr]

pOr :: Parser Term
pOr = chainl1 pAnd (sym "|" >> return (\a b -> Fun "_or" [a, b]))

pAnd :: Parser Term
pAnd = chainl1 pTerm (sym "&" >> return (\a b -> Fun "_and" [a, b]))

parseQuery :: String -> Either ParseError Query
parseQuery = parse pQuery "<query>"
\end{code}
