/* Subway sandwich interactor */

/* Food Menu */
breads([parmesan, honeywheat, wheat, italian, flat]).
main([chicken, tuna, ham, bacon, meatball, turkey, steak]).
veggies([lettuce, tomato, cucumber, green_pepper, onion, spinach, black_olive]). 
sauce([mustard, chipotle, barbecue, honey_mustard, vinegar, cheese]).
sides([soup, soda, cookie, salad, chips]).

/* Food attribute */
not_vegan(cheese).
not_healthy(bacon).
not_healthy(meatball).
not_healthy(steak).
not_healthy(cheese).
not_healthy(barbecue).
not_healthy(soda).
not_healthy(chips).

:-style_check(-singleton). /* suppress singleton warning */

/* Welcome screen */
:- writeln('*** PS: For best experience, please run the script in full screen :D ***').
:- writeln(" ").
:- writeln('Welcome to Subway Sandwich Interactor. How may I help you?').
:- writeln(" ").
:- writeln('1. options(X)  : See what we offer for X. X can be any of the following: | breads | main | veggies | sauce | sides |').
:- writeln(" ").
:- writeln('2. start(1)    : Start ordering :D').
:- writeln(" ").
:- writeln('3. restart(1)  : Restart order').
:- writeln(" ").
:- writeln("===================================================================================================================").

/* Display items from each options */
options(breads) :- breads(X), write('Available in 6-inch and footlong sizes: '), write(X).
options(main) :- main(X), write('Guarantee fresh and tasty: '), write(X).
options(veggies) :- veggies(X), write('Our wide variety of fresh veggies: '), write(X).
options(sauce) :- sauce(X), write('Finish off your sandwich with one of our delicious sauces: '), write(X).
options(sides) :- sides(X), write('Our sandwiches are even better when paired with the perfect sides: '), write(X).

:- dynamic(selected/2). /* stores selected items */
:- dynamic(flag/1). /* flags for flow control */
/* pre-initializes list for item that can be selected more than once. */
selected([], veggie).
selected([], sauce).
selected([], side).
/* print items from list and if applicable, filter out non-vegan or unhealthy item */
print([]). /* terminating case */
/* skip if customer chose vegan or healthy meal option */
print([H|T]) :- (not_vegan(H), selected(vegan, meal); not_healthy(H), selected(healthy, meal)), print(T), !. 
print([H|T]) :- write(H), write(" | "), print(T), !.

/* Customization sequence */
start(1) :- write('Choose meal options (type \'select(X)\'): normal | vegan | healthy | value |').
/* handle select meal */
select(X) :- \+flag(meal), assertz(flag(meal)), assertz(selected(X, meal)), 
             write('Choose a bread (type \'select(X)\'): '), breads(Y), print(Y), !.
/* handle select bread, if customer chose vegan meal, skip main selection */
select(X) :- \+selected(vegan, meal), breads(Y), member(X, Y), assertz(selected(X, bread)), 
             write('Choose a main fillings (type \'select(X)\'): '), main(Z), print(Z), !.
select(X) :- selected(vegan, meal), breads(Y), member(X, Y), assertz(selected(X, bread)), 
             write('Choose a veggie toppings (type \'select(X)\'): '), veggies(Z), print(Z), !. 
/* handle select main */
select(X) :- main(Y), member(X, Y), assertz(selected(X, main)), 
             write('Choose a veggie toppings (type \'select(X)\'): '), veggies(Z), print(Z), !.
/* handle select veggie */
select(X) :- veggies(Y), member(X, Y), selected(L, veggie), retract(selected(_, veggie)), append(L, [X], R), assertz(selected(R, veggie)), 
             write('Do you want to choose more? (Type \'yes()\' or \'no()\'. No extra charges needed :D)'), !.
/* handle select sauce */
select(X) :- sauce(Y), member(X, Y), selected(L, sauce), retract(selected(_, sauce)), append(L, [X], R), assertz(selected(R, sauce)), 
             assertz(flag(sauce)), write('Do you want to choose more? (Type \'yes()\' or \'no()\'. No extra charges needed :D)'), !.
/* handle select sides */
select(X) :- sides(Y), member(X, Y), selected(L, side), retract(selected(_, side)), append(L, [X], R), assertz(selected(R, side)), 
             assertz(flag(side)), write('Do you want to choose more? (Type \'yes()\' or \'no()\'. No extra charges needed :D)'), !.
             
/* predicates to handle yes(), no() options */
yes() :- \+flag(sauce), write('Choose another veggie toppings (type \'select(X)\'): '), veggies(Z), print(Z), !.
yes() :- \+flag(side), flag(sauce), write('Choose another sauce (type \'select(X)\'): '), sauce(Z), print(Z), !.
yes() :- \+flag(done), flag(side), write('Choose another sides (type \'select(X)\'): '), sides(Z), print(Z), !.
no() :- \+flag(sauce), write('Choose a sauce (type \'select(X)\'): '), sauce(Z), print(Z), !.
no() :- \+selected(value, meal), \+flag(side), flag(sauce), write('Choose a sides (type \'select(X)\'): '), sides(Z), print(Z), !.
no() :- \+flag(done), flag(side), assertz(flag(done)), write('Type \'done(1)\' to check out'), !.
no() :- \+flag(done), selected(value, meal), assertz(flag(done)), write('Type \'done(1)\' to check out'), !.

/* Checkout screen */
done(1) :- write('You ordered '), selected(M, meal), write([M]), write(' meal option, with '), selected(A, bread), write([A]), write(' for bread, '), 
           (selected(B, main), write([B]), write(' for main fillings, ');selected(vegan, meal)),
           selected(C, veggie), write(C), write(' for veggies, '), selected(D, sauce), write(D), write(' for sauce and '), selected(E, side), write(E), 
           writeln(' for sides.'), write('Thank you for using Subway Sandwich Interactor. See you again soon! :)'), !.

/* delete all flags and reinitialize selected predicate then start over */
restart(1) :- retractall(flag(X)), retractall(selected(Y, Z)), assertz(selected([], veggie)),
              assertz(selected([], sauce)), assertz(selected([], side)), start(1).