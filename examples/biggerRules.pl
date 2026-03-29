bigger(cat(), mouse()):-.
bigger(dog(), cat()):-.
bigger(horse(), dog()):-.
is_bigger(A,B):- bigger(A,B)
is_bigger(A,B):- bigger(A,Z) & is_bigger(Z,B).

% Example from here: https://swish.swi-prolog.org/p/introduction_to_logic_and_programming.swinb