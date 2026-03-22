bigger(cat(), mouse()):-
bigger(dog(), cat()):-
bigger(horse(), dog()):-
is_bigger(A,B):- bigger(A,B)
is_bigger(A,B):- bigger(A,Z) & is_bigger(Z,B)