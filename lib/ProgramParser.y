{
module ProgramParser where
import RuleLexer
import Terms
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
    '&'     {AND}
    ":-"    {IF}
    "|"     {OR}

%%

Program
    :                       {[]}
    | Clause '.' Program    { $1 : $3 }
Clause
    : Term ":-"             {Fact $1}
    | Term ":-" Assum       {Rule $1 $3}

Assum
    : Term   { $1 : [] }
    | Term '&' Assum    { $1 : $3 }

Term
    : funname '(' Terms ')' {Fun $1 $3}
    | varname               {Var $1}

Terms
    :                   {[]}
    | Term              {$1 :[]}
    | Term ',' Terms    {$1 : $3}

{parseError :: [Token] -> a
parseError _ = error "Parse error"

pProgram:: String -> [Clause]
pProgram = parseProgram . alexScanTokens}
