%start game setup
clue :- write("Number of players? "), read(Num), 
    write("List Player Names (lowercase only) \n"), players(Num,1), 
    write("List Weapons (lowercase only) \n"), weapons(6), 
    write("List Suspect Names (lowercase only) \n"),suspects(6), 
    write("List Room Names (lowercase only) \n"),rooms(9),
	bagof(X,weapon(X),A), assert(currWeapons(A)),
	bagof(Y,suspect(Y),B), assert(currSuspects(B)),
	bagof(Z,room(Z),C), assert(currRooms(C)),
    playerCards, play.

%prompt for player names
players(1, Num) :- write("Last Player Name: "), read(Last), assert(player(Last,Num)).
players(Num, Num2) :- write("Player Name: "), read(Play), assert(player(Play, Num2)), 
                NewNum is Num - 1, NewNum2 is Num2 + 1,players(NewNum,NewNum2).

%prompt for weapons
weapons(1) :- write("Last Weapon Name: "), read(Last), assert(weapon(Last)).
weapons(Num) :- write("Weapon Name: "), read(Weapon), assert(weapon(Weapon)), 
                NewNum is Num - 1, weapons(NewNum).

%prompt for suspect names
suspects(1) :- write("Last Suspect Name: "), read(Last), assert(suspect(Last)).
suspects(Num) :- write("Supect Name: "), read(Name), assert(suspect(Name)), 
                NewNum is Num - 1, suspects(NewNum).

%prompt for room names
rooms(1) :- write("Last Room Name: "), read(Last), assert(room(Last)).
rooms(Num) :- write("Room Name: "), read(Room), assert(room(Room)), 
                NewNum is Num - 1, rooms(NewNum).

%console for actions
play :- checkWin, 
		write("Please choose a number :\n 1. View notebook \n 2. Record your move \n"), 
        write(" 3. Record other players move \n 4. Give suggestion \n 5. Quit\n"), 
        read(X), choice(X).

%possible choices
choice(1) :- printNotebook, play.
choice(2) :- yourMove, play.
choice(3) :- write("Who's turn is it?"), read(X), player(X, PlayerNum), 
            otherMove(PlayerNum), play.
choice(4) :- suggest, play.
choice(5).

%record your move and recording it
yourMove :- write("What did you ask to see from "), player(X,2), write(X), write("?\n"),
            write("Room? "), read(R), write("Weapon? "), read(W), write("Suspect? "), 
            read(S), room(R), weapon(W), suspect(S), write("Do they have it? yes or no "), 
            read(Answer), have(Answer,2).

%when the player you asked has one of the three cards
have(yes, PlayerNum) :- write("What card was it?"), read(Card), valid(Card,Type), 
                    assert(not(Card,Type,PlayerNum)), play.

%when the player you asked does not have one of the three cards
have(no, PlayerNum) :- Next is PlayerNum+1, (player(X, Next) -> write("Does "), write(X), 
                        write(" have it?"), read(NewAnswer), have(NewAnswer,Next); 
                        write("No one has these three cards. \n\n"), play). 

%prompt for other player's move and record
otherMove(PlayerNum) :- player(X,PlayerNum), Next is PlayerNum+1, player(Y, Next),
                write("What does "),write(X), write(" ask "), write(Y), write("?\n"),
                write("Room? "), read(R), write("Weapon? "), read(W), write("Suspect? "), 
                read(S), room(R), weapon(W), suspect(S),    
                write("Does "), write(X), write(" show "), write(Y), write(" anything?").

%prompt players for their cards
playerCards :- write("What cards do you hold? List cards within [] and separated by commas.\n"),
                read(X), inputCards(X).

%checks if card is valid and adds it to our current database
inputCards([H]) :- weapon(H), assert(not(H, weapon, 1)).
inputCards([H]) :- suspect(H), assert(not(H, suspect, 1)).
inputCards([H]) :- room(H), assert(not(H, room, 1)).
inputCards([H|T]) :- weapon(H),assert(not(H, weapon, 1)),inputCards(T).
inputCards([H|T]) :- suspect(H),assert(not(H, suspect, 1)),inputCards(T).
inputCards([H|T]) :- room(H),assert(not(H, room, 1)),inputCards(T).

%test if an inputted card is valid
valid(Card,weapons) :- weapon(Card).
valid(Card,suspect) :- suspect(Card).
valid(Card,room) :- room(Card).

%prints the contents of the notebook
printNotebook :-% writes all the names of the players 
                write("\t\t"),forall(player(X,_Y), format("~w \t\t", X)), write("\n"),
                findall(X, player(_,X), Y),
                forall(weapon(A), printPad(A,Y,'')), write("\n"),
                forall(suspect(B), printPad(B,Y,'')), write("\n"),
                forall(room(C), printPad(C,Y,'')), write("\n").

%builds string to represent which player has what card
printPad(Card, [], Str) :- string_concat(Card, "\t", NewCard), string_concat(NewCard, Str, NewStr), format("~w\n", NewStr).
printPad(Card, [H|T], Str) :- (not(Card,_,H) -> string_concat(Str, "\tX\t", NewStr); 
                string_concat(Str, "\t\t", NewStr)), printPad(Card,T,NewStr). 

checkWin:- 	bagof(Y1,weapon(Y1),A1),findall(X1,not(X1,weapon,_),Z1),length(Z1,5),subtract(A1,Z1,[New1]),assert(right(New1)),
			bagof(Y2,room(Y2),A2),findall(X2,not(X2,room,_),Z2),length(Z2,8),subtract(A2,Z2,[New2]),assert(right(New2)),
			bagof(Y3,suspect(Y3),A3),findall(X3,not(X3,suspect,_),Z3),length(Z3,5),subtract(A3,Z3,[New3]),assert(right(New3)),
			bagof(A,right(A),Z),format("SUGGEST THE FOLLOWING: ~w \t~w \t~w",Z).
