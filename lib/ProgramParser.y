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

%%

Program
    :                       {Right []}
    | Clause '.' Program    { case $3 of
                                Left e  -> Left e
                                Right xs -> Right ($1 : xs)
                              }
Clause
    : Term                {Fact $1}
    | Term ":-"          {Fact $1}
    | Term ":-" Assum    {Rule $1 $3}

Assum
    : Term   { $1 : [] }
    | Term ',' Assum    { $1 : $3 }

Term
    : funname '(' Terms ')' {Fun $1 $3}
    | funname                {Fun $1 []}
    | varname               {Var $1}

Terms
    :                   {[]}
    | Term              {$1 :[]}
    | Term ',' Terms    {$1 : $3}

{parseError :: [Token] -> a
parseError tokens =
  let ctx = take 8 tokens
      msg = "Parse error near tokens: " ++ show ctx
  in unsafeCoerce (Left (msg :: String) :: Either String [Clause])

pProgram:: String -> Either String [Clause]
pProgram = parseProgram . alexScanTokens}
