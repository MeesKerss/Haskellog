{
module ProgramParserWithOr where
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
    :                       {[Rule (Fun "and" [Var "X",Var "Y"]) [Var "X",Var "Y"],Rule (Fun "and" [Var "X",Var "Y"]) [Var "Y",Var "X"],Rule (Var "X") [Fun "or" [Var "X",Var "Y"]],Rule (Var "Y") [Fun "or" [Var "X",Var "Y"]]]}
    | Clause '.' Program    { $1 : $3 }
Clause
    : Term ":-"             {Fact $1}
    | Term                  {Fact $1}
    | Term ":-" Assum       {Rule $1 $3}

Assum
    : Conj              { $1 }
    | Assum2 "|" Conj1    {(Fun "or" [$3,$1]):[]}
Assum2
    : Conj1              { $1 }
    | Assum2 "|" Conj1    {(Fun "or" [$3,$1])}

Conj
    : ConjChild             { $1:[] }
    | ConjChild '&' Conj    {$1: $3}

Conj1
    : ConjChild1             { $1 }
    | Conj1 '&' ConjChild1    {Fun "and" [$1,$3]}

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
    | varname               {Var $1}

Terms
    :                   {[]}
    | Term              {$1 :[]}
    | Term ',' Terms    {$1 : $3}

{parseError :: [Token] -> a
parseError _ = error "Parse error"

pProgram:: String -> [Clause]
pProgram = programParserWithOr . alexScanTokens}
