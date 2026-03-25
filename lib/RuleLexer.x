{
module RuleLexer where
import Terms
}
%wrapper "basic"

$highkey = [A-Z]
$lowkey = [a-z]
$restOfName = [a-zA-Z]
$white = [ \n\t]

@varName = $highkey $restOfName*
@funName   = $lowkey $restOfName*

tokens :-

    $white              ;
    @varName            { \s -> VARNAME s }
    @funName            { \s -> FUNNAME s }
    \.                  { \_ -> ENDOFRULE}
    \,                  { \_ -> VARSEP}
    \&                  { \_ -> AND }
    ":-"                { \_ -> IF }
    \(                  { \_ -> LPAREN }
    \)                  { \_ -> RPAREN }

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
  deriving (Show, Eq)
}