%start game setup
clue :- reset,
        write("All input must begin with lowercase letters and end with a period.\n"),
		write("Number of players (3-6)? "), read(Num), validNum(Num),
		write("List Player Names within [] and seperated by commas (lowercase only) \n"), 
        read(Players),players(Players,1), 
		write("Is this the default version of clue(yes/no)? \n"), read(Default),
		(Default == 'yes' ->
			assert(suspect(scarlet)), assert(suspect(plum)), assert(suspect(mustard)),
			assert(suspect(green)), assert(suspect(white)), assert(suspect(peacock)),
			assert(weapon(rope)), assert(weapon(pipe)), assert(weapon(knife)),
			assert(weapon(wrench)), assert(weapon(candlestick)), assert(weapon(pistol)),
			assert(room(kitchen)), assert(room(ballroom)), assert(room(conservatory)),
			assert(room(dining_room)), assert(room(billiard_room)), assert(room(library)),
			assert(room(lounge)), assert(room(hall)), assert(room(study)),printNotebook,
            assert(numWeapons(6)), assert(numSuspects(6)), assert(numRooms(9));
			write("List Weapons (13 Characters max).\nList cards within [] and separated by commas.\n"),
            read(Weapons), length(Weapons, WepLen), assert(numWeapons(WepLen)), weapons(Weapons), 
			write("List Suspect Names (13 Characters max).\nList cards within [] and separated by commas. \n"), 
            read(Suspects), length(Suspects, SusLen), assert(numSuspects(SusLen)), suspects(Suspects), 
			write("List Room Names (13 Characters max).\nList cards within [] and separated by commas. \n"), 
            read(Rooms), length(Rooms, RoomLen), assert(numRooms(RoomLen)), rooms(Rooms)),
		playerCards, play.
		
reset :- retractall(weapon(_)), retractall(room(_)), retractall(player(_,_)), retractall(right(_)),
		 retractall(suspect(_)), retractall(not(_,_,_)), retractall(doesNotOwn(_,_, _)),
		 retractall(unknownRooms(_)),retractall(unknownSuspects(_)),retractall(unknownWeapons(_)),
		 retractall(numWeapons(_)), retractall(numSuspects(_)), retractall(numRooms(_)).

%checks for valid number of players
validNum(3).
validNum(4).
validNum(5).
validNum(6).

%asserting the player names
players([], _).
players([H|T], Num) :- assert(player(H,Num)), Num2 is Num + 1, players(T,Num2).

%asserting the weapons names
weapons([]).
weapons([H|T]) :- assert(weapon(H)),weapons(T).

%asserting the suspect names
suspects([]).
suspects([H|T]) :- assert(suspect(H)),suspects(T).

%asserting the room names
rooms([]).
rooms([H|T]) :- assert(room(H)),rooms(T).
				
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
play :- (checkWin -> bagof(A,right(A),Z),format("SUGGEST THE FOLLOWING: ~w ~w ~w\n",Z),abort;true),
		write("Please choose a number :\n 1. View notebook \n 2. Record your move \n"), 
        write(" 3. Record other players move \n 4. Give suggestion \n 5. Quit\n"), 
        read(X), choice(X).

%possible choices
choice(1) :- printNotebook, play.
choice(2) :- yourMove, play.
choice(3) :- write("Who's turn is it?"), read(X), player(X, PlayerNum), 
             Next is PlayerNum+1, otherMove(PlayerNum, Next), play.
choice(4) :- suggestions, play.
choice(5) :- abort.

% give a suggestion
suggestions :- getSuspect(Suspect), getWeapon(Weapon), getRoom(Room),
			   format("\nYou should suggest ~w in the ~w with the ~w.\n\n",[Suspect,Room,Weapon]), sleep(2).

getSuspect(Suspect) :- unknownSuspects([Suspect|_Etc]).
getWeapon(Weapon) :- unknownWeapons([Weapon|_Etc]).
getRoom(Room) :- unknownRooms([Room|_Etc]).

%record your move and recording it
yourMove :- write("What did you ask to see from "), player(X,2), write(X), write("?\n"),
            write("Weapon? "), read(W), write("Suspect? "), read(S),
			write("Room? "), read(R),room(R), weapon(W), suspect(S), write("Do they have it? (yes/no) "), 
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

					
%asserts the cards that are not owned by the other players when shwon a card
crossExtras(_Card, _Type, End, End).
crossExtras(Card, Type, End, Current) :- player(_,Current), assert(doesNotOwn(Card,Type,Current)),
										 Next is Current + 1, crossExtras(Card,Type,End,Next).
crossExtras(Card, Type, End, _Current) :- crossExtras(Card,Type,End,1).
						
%prompt for other player's move and record
otherMove(Origin, Asked) :- player(X,Origin),player(Y, Asked),
                            format("What does ~w ask ~w?\n", [X,Y]),
                            write("Weapon? "), read(W), write("Suspect? "), 
                            read(S), write("Room? "), read(R), 
                            format("Does ~w show ~w anything? (yes/no) ", [X,Y]),
                            read(Response), readResponse(Response,[R,W,S],Origin,Asked). 
                          
%if the other player is asking the user for a card
otherMove(Origin, _) :- player(X,Origin), format("What does ~w ask you?\n", X),
                        write("Weapon? "), read(W), write("Suspect? "), read(S), 
                        write("Room? "), read(R), readResponse(yes, [W,S,R], Origin, 1).   
                            
%If the person being asked does have the cards                         
%readResponse(yes, [R,W,S], Origin, Asked) :- .

%If the person being asked does not have the cards
readResponse(no,[W,S,R], Origin, Asked) :- assert(doesNotOwn(W,weapon,Asked)),
                                           assert(doesNotOwn(S,suspect,Asked)),
                                           assert(doesNotOwn(R,room,Asked)), Next is Asked+1,
                                           (Next == Origin -> write("No one has these cards.\n\n"), play; true),
                                           (player(X,Origin),player(Y,Next) -> 
                                           format("Does ~w show ~w anything? (yes/no) ", [X,Y]), 
                                           read(Response), readResponse(Response, [W,S,R], Origin, Next);
                                           readResponse(yes, [W,S,R], Origin, 1)).

%used when the user is asked if they have the cards
readResponse(_,[W,S,R],Origin,1) :- write("Do you have the cards? (yes/no)"), read(Response),
                                    (Response == 'yes' -> recommend([W,S,R]), play; 
                                    (Origin == 2 -> write("No one has these cards.\n\n"), play;
                                    player(X,Origin), player(Y,2), 
                                    format("Does ~w show ~w anything? (yes/no) ", [X,Y]), read(Res),
                                    readResponse(Res,[W,S,R],Origin,2))).

%asserting cards that are owned by the player
doesNotHave(_Card, _Type, Player) :- not(player(_,Player)).
doesNotHave(Card, Type, Player) :- player(_,Player), assert(doesNotOwn(Card, Type, Player)), 
                                   NewPlayer is Player + 1, doesNotHave(Card,Type,NewPlayer).

%test if an inputted card is valid
valid(Card,weapon) :- weapon(Card).
valid(Card,suspect) :- suspect(Card).
valid(Card,room) :- room(Card).

%prints the contents of the notebook
printNotebook :- % writes all the names of the players 
                 write("\t\t"),forall(player(X,_Y), format("~32t~15| ~w", X)), write("\n"),
                 findall(X, player(_,X), PlayerList),
                 forall(weapon(A), printPad(A,PlayerList,'')), write("\n"),
                 forall(suspect(B), printPad(B,PlayerList,'')), write("\n"),
                 forall(room(C), printPad(C,PlayerList,'')), write("\n").

%prints out the newly built string for each row in the table
printPad(Card, [], Str) :-    format("~w ~32t ~15|~w ~n", [Card,Str]). 

%builds string to represent which player has what card
printPad(Card, [H|T], Str) :- (not(Card,_,H) -> string_concat(Str, "\tO\t", NewStr);
							  (doesNotOwn(Card,_,H)-> string_concat(Str, "\tX\t", NewStr); 
							  string_concat(Str, "\t\t", NewStr))), printPad(Card,T,NewStr).

							  
%checks if a winning solution has been found
checkWin :- retractall(right(_)),
			bagof(Y1,weapon(Y1),A1),findall(X1,not(X1,weapon,_),Z1),subtract(A1,Z1,New1),
			retract(unknownWeapons(_)),assert(unknownWeapons(New1)),
			bagof(Y2,room(Y2),A2),findall(X2,not(X2,room,_),Z2),subtract(A2,Z2,New2),
			retract(unknownRooms(_)),assert(unknownRooms(New2)),
			bagof(Y3,suspect(Y3),A3),findall(X3,not(X3,suspect,_),Z3),subtract(A3,Z3,New3),
			retract(unknownSuspects(_)),assert(unknownSuspects(New3)),
			length(New1,1),New1 = [LastWeapon],assert(right(LastWeapon)),
			length(New2,1),New2 = [LastRoom],assert(right(LastRoom)),
			length(New3,1), New3 = [LastSus],assert(right(LastSus)).