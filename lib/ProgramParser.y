{
module ProgramParser where
import RuleLexer
import Terms
import Unsafe.Coerce (unsafeCoerce)
}

%name parseProgram
%tokentype {Token}
%error {parseError}

%token
    funname {FUNNAME $$}
    varname {VARNAME $$}
    '.'     {ENDOFRULE}
    '('     {LPAREN}
    ')'     {RPAREN}
    ','     {VARSEP}
    ":-"    {IF}
    "|"     {OR}
    '&'     {AND}

%%

Program
    :                       {Right [Rule (Fun "_and" [Var "_X",Var "_Y"]) [Var "_X",Var "_Y"],Rule (Fun "_or" [Var "_X",Var "_Y"]) [Var "_X"],Rule (Fun "_or" [Var "_X",Var "_Y"]) [Var "_Y"]]}
    | Clause '.' Program    { case $3 of
                                Left e  -> Left e
                                Right xs -> Right ($1 : xs)
                              }


Clause
    : Term ":-"             {Fact $1}
    | Term                  {Fact $1}
    | Term ":-" Assum       {Rule $1 $3}

Assum
    : Conj              { $1 }
    | Assum2 "|" Conj1    {(Fun "_or" [$3,$1]):[]}
Assum2
    : Conj1              { $1 }
    | Assum2 "|" Conj1    {(Fun "_or" [$3,$1])}

Conj
    : ConjChild             { $1:[] }
    | ConjChild '&' Conj    {$1: $3}

Conj1
    : ConjChild1             { $1 }
    | Conj1 '&' ConjChild1    {Fun "_and" [$1,$3]}

ConjChild1
    : Term                  {$1}
    | '('Assum2')'           {$2}
ConjChild
    : Term                  {$1}
    | '('Assum2')'           {$2}
{-Assum
    : Term   { $1 : [] }
    | Term '&' Assum    { $1 : $3 }-}

Term
    : funname '(' Terms ')' {Fun $1 $3}
    | funname               {Fun $1 []}
    | varname               {Var $1}

Terms
    :                   {[]}
    | Term              {$1 :[]}
    | Term ',' Terms    {$1 : $3}

{
parseError :: [Token] -> a
parseError tokens =
  let ctx = take 8 tokens
      msg = "Parse error near tokens: " ++ show ctx
  in unsafeCoerce (Left (msg :: String) :: Either String [Clause])

pProgram:: String -> Either String [Clause]
pProgram = parseProgram . alexScanTokens}

-- written with the help of this article: https://blog.cofree.coffee/2021-10-29-happy-and-alex-part-1-dont-worry-be-happy/
