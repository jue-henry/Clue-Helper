%start game setup
clue :- retractall(weapon(_Wep)), retractall(room(_Room)), retractall(player(_Name,_Number)), 
		retractall(suspect(_Sus)), retractall(not(_Card,_Type,_PlayNum)), 
		retractall(doesNotOwn(_Car,_Typ, _PlayN)),
		write("Number of players (3-6)? "), read(Num), validNum(Num),
		write("List Player Names (lowercase only) \n"), read(Players),players(Players,1), 
		write("Is this the default version of clue(yes/no)? \n"), read(Default),
		(Default == 'yes' ->
			assert(suspect(scarlet)), assert(suspect(plum)), assert(suspect(mustard)),
			assert(suspect(green)), assert(suspect(white)), assert(suspect(peacock)),
			assert(weapon(rope)), assert(weapon(pipe)), assert(weapon(knife)),
			assert(weapon(wrench)), assert(weapon(candlestick)), assert(weapon(pistol)),
			assert(room(kitchen)), assert(room(ballroom)), assert(room(conservatory)),
			assert(room(dining_room)), assert(room(billiard_room)), assert(room(library)),
			assert(room(lounge)), assert(room(hall)), assert(room(study)),printNotebook;
			write("List Weapons (lowercase only) \n"), read(Weapons), weapons(Weapons), 
			write("List Suspect Names (lowercase only) \n"), read(Suspects),suspects(Suspects), 
			write("List Room Names (lowercase only) \n"), read(Room),rooms(Room)),
		bagof(X,weapon(X),A), assert(currWeapons(A)),
		bagof(Y,suspect(Y),B), assert(currSuspects(B)),
		bagof(Z,room(Z),C), assert(currRooms(C)),
		playerCards, play.

validNum(3).
validNum(4).
validNum(5).
validNum(6).

%prompt for player names
%players(1, Num) :- write("Last Player Name: "), read(Last), assert(player(Last,Num)).
%players(Num, Num2) :- write("Player Name: "), read(Play), assert(player(Play, Num2)),
%                NewNum is Num - 1, NewNum2 is Num2 + 1,players(NewNum,NewNum2).

players([], _).
players([H|T], Num) :- assert(player(H,Num)), Num2 is Num + 1, players(T,Num2).

%prompt for weapons
%weapons(1) :- write("Last Weapon Name: "), read(Last), assert(weapon(Last)).
%weapons(Num) :- write("Weapon Name: "), read(Weapon), assert(weapon(Weapon)), 
%                NewNum is Num - 1, weapons(NewNum).
				
weapons([]).
weapons([H|T]) :- assert(weapon(H)),weapons(T).

suspects([]).
suspects([H|T]) :- assert(suspect(H)),suspects(T).

rooms([]).
rooms([H|T]) :- assert(room(H)),rooms(T).

%prompt for suspect names
%suspects(1) :- write("Last Suspect Name: "), read(Last), assert(suspect(Last)).
%suspects(Num) :- write("Supect Name: "), read(Name), assert(suspect(Name)), 
%                NewNum is Num - 1, suspects(NewNum).

%prompt for room names
%rooms(1) :- write("Last Room Name: "), read(Last), assert(room(Last)).
%rooms(Num) :- write("Room Name: "), read(Room), assert(room(Room)), 
%                NewNum is Num - 1, rooms(NewNum).
				
%prompt players for their cards
playerCards :- write("What cards do you hold? List cards within [] and separated by commas.\n"),
                read(X), inputCards(X).

%checks if card is valid and adds it to our current database
inputCards([H]) :- weapon(H), assert(not(H, weapon, 1)), doesNotHave(H,weapon,2).
inputCards([H]) :- suspect(H), assert(not(H, suspect, 1)),doesNotHave(H,suspect,2).
inputCards([H]) :- room(H), assert(not(H, room, 1)), doesNotHave(H,room,2).
inputCards([H|T]) :- weapon(H),assert(not(H, weapon, 1)),doesNotHave(H,weapon,2),inputCards(T).
inputCards([H|T]) :- suspect(H),assert(not(H, suspect, 1)),doesNotHave(H,suspect,2),inputCards(T).
inputCards([H|T]) :- room(H),assert(not(H, room, 1)),doesNotHave(H,room,2),inputCards(T).
inputCards(_) :- write("One of your inputted cards is incorrect. Try Again. \n"),
				 retractall(not(_,_,_)), retractall(doesNotOwn(_,_,_)), playerCards.

%console for actions
play :- (checkWin -> 
			bagof(A,right(A),Z),format("SUGGEST THE FOLLOWING: ~w \t~w \t~w",Z);true),
		write("Please choose a number :\n 1. View notebook \n 2. Record your move \n"), 
        write(" 3. Record other players move \n 4. Give suggestion \n 5. Quit\n"), 
        read(X), choice(X).

%possible choices
choice(1) :- printNotebook, play.
choice(2) :- yourMove, play.
choice(3) :- write("Who's turn is it?"), read(X), player(X, PlayerNum), 
            otherMove(PlayerNum), play.
choice(4).
choice(5) :- abort.

%record your move and recording it
yourMove :- write("What did you ask to see from "), player(X,2), write(X), write("?\n"),
            write("Weapon? "), read(W), write("Suspect? "), read(S),
			write("Room? "), read(R),room(R), weapon(W), suspect(S), write("Do they have it? yes or no "), 
            read(Answer), have(Answer,[W,R,S],2).

%when the player you asked has one of the three cards
have(yes, List, PlayerNum) :- write("What card was it?"), read(Card), member(Card, List), valid(Card,Type), 
							  assert(not(Card,Type,PlayerNum)), NextPlayer is PlayerNum + 1,
							  crossExtras(Card, Type,PlayerNum, NextPlayer), play.

%when the player you asked does not have one of the three cards
have(no, [W,R,S], PlayerNum) :- Next is PlayerNum+1, assert(doesNotOwn(W,weapon,PlayerNum)),
								assert(doesNotOwn(R,room,PlayerNum)), assert(doesNotOwn(S,suspect,PlayerNum)),
								(player(X, Next) -> write("Does "), write(X), 
								write(" have it?"), read(NewAnswer), have(NewAnswer, [W,R,S], Next); 
								write("No one has these three cards. \n\n"), play). 

					
crossExtras(_Card, _Type, End, End).
crossExtras(Card, Type, End, Current) :- player(_,Current), assert(doesNotOwn(Card,Type,Current)),
										 Next is Current + 1, crossExtras(Card,Type,End,Next).
crossExtras(Card, Type, End, _Current) :- crossExtras(Card,Type,End,1).
						
%prompt for other player's move and record
otherMove(PlayerNum) :- player(X,PlayerNum), Next is PlayerNum+1, player(Y, Next),
                write("What does "),write(X), write(" ask "), write(Y), write("?\n"),
                write("Room? "), read(R), write("Weapon? "), read(W), write("Suspect? "), 
                read(S), room(R), weapon(W), suspect(S),    
                write("Does "), write(X), write(" show "), write(Y), write(" anything?").

doesNotHave(_Card, _Type, Player):- not(player(_,Player)).
doesNotHave(Card, Type, Player):- player(_,Player), assert(doesNotOwn(Card, Type, Player)), NewPlayer is Player + 1,
								  doesNotHave(Card,Type,NewPlayer).

%test if an inputted card is valid
valid(Card,weapons) :- weapon(Card).
valid(Card,suspect) :- suspect(Card).
valid(Card,room) :- room(Card).

%prints the contents of the notebook
printNotebook :-% writes all the names of the players 
                write("\t\t"),forall(player(X,_Y), format("~w \t", X)), write("\n"),
                findall(X, player(_,X), PlayerList),
                forall(weapon(A), printPad(A,PlayerList,'')), write("\n"),
                forall(suspect(B), printPad(B,PlayerList,'')), write("\n"),
                forall(room(C), printPad(C,PlayerList,'')), write("\n").

%builds string to represent which player has what card
printPad(Card, [], Str) :- string_concat(Card, "\t", NewCard), string_concat(NewCard, Str, NewStr), format("~w\n", NewStr).
printPad(Card, [H|T], Str) :- (not(Card,_,H) -> string_concat(Str, "\tO", NewStr);
							  (doesNotOwn(Card,_,H)-> string_concat(Str, "\tX", NewStr); 
							  string_concat(Str, "\t", NewStr))),
							  printPad(Card,T,NewStr).
				
checkWin:- 	bagof(Y1,weapon(Y1),A1),findall(X1,not(X1,weapon,_),Z1),length(Z1,5),subtract(A1,Z1,[New1]),assert(right(New1)),
			bagof(Y2,room(Y2),A2),findall(X2,not(X2,room,_),Z2),length(Z2,8),subtract(A2,Z2,[New2]),assert(right(New2)),
			bagof(Y3,suspect(Y3),A3),findall(X3,not(X3,suspect,_),Z3),length(Z3,5),subtract(A3,Z3,[New3]),assert(right(New3)).