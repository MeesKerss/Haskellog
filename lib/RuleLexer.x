{
module RuleLexer where
import Terms
}
%wrapper "basic"

$highkey = [A-Z]
$lowkey = [a-z]
$restOfName = [a-zA-Z0-9_]
--$white = [ \n\t]

@varName = $highkey $restOfName*
@funName   = $lowkey $restOfName*

tokens :-

    $white+              ;
    \% [^\n]*             ;
    @varName            { \s -> VARNAME s }
    @funName            { \s -> FUNNAME s }
    \.                  { \_ -> ENDOFRULE}
    \,                  { \_ -> VARSEP}
    \&                  { \_ -> AND }
    ":-"                { \_ -> IF }
    \(                  { \_ -> LPAREN }
    \)                  { \_ -> RPAREN }
    \|                  { \_ -> OR}

{
data Token
  = FUNNAME String
  | VARNAME Variable
  | ENDOFRULE
  | LPAREN
  | RPAREN
  | VARSEP
  | AND
  | IF
  | OR
  deriving (Show, Eq)
}