\begin{code}
module Parser where

import Text.Parsec
import Text.Parsec.String (Parser)

import Syntax


type Query = [Term]

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
  return $ Struct (first : rest) []

pStruct :: Parser Term
pStruct = lexeme $ do
  first <- lower
  rest  <- many (alphaNum <|> char '_')
  let name = first : rest
  args <- between (sym "(") (sym ")") (pTerm `sepBy` sym ",")
  return $ Struct name args

pTerm :: Parser Term
pTerm = try pStruct <|> try pVar <|> pAtom

pQuery :: Parser Query
pQuery = do
  ws
  optional (try (sym "?-"))
  goals <- pTerm `sepBy1` sym ","
  optional (sym ".")
  eof
  return goals

parseQuery :: String -> Either ParseError Query
parseQuery = parse pQuery "<query>"
\end{code}