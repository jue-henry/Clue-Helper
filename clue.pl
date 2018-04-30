% Programmers:
% 	Va Vong 	- 912673787
%	Henry Jue 	- 913037267

%start game setup
clue :- reset,
        write("All input must begin with lowercase letters and end with a period.\n"),
		    write("Number of players (3-6)? "), read(Num), validNum(Num), assert(numPlayers(Num)),
		    write("List Player Names within [] and seperated by commas (lowercase only) \n"),
        read(Players),
        (length(Players,Num) -> players(Players,1); write("Incorrect number of names.\n\n"),clue),
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
    bagof(A,suspect(A),TotSuspects),bagof(B,weapon(B),TotWeapons), bagof(Z,room(Z),TotRooms),
    assert(allSuspects(TotSuspects)), assert(allWeapons(TotWeapons)), assert(allRooms(TotRooms)),
		playerCards,!, play.

reset :- retractall(weapon(_)), retractall(room(_)), retractall(player(_,_)), retractall(right(_,_)),
		     retractall(suspect(_)), retractall(not(_,_,_)), retractall(doesNotOwn(_,_, _)),
		     retractall(unknownRooms(_)),retractall(unknownSuspects(_)),retractall(unknownWeapons(_)),
		     retractall(numWeapons(_)), retractall(numSuspects(_)), retractall(numRooms(_)),
		     retractall(maybeCount(_,_,_)), retractall(shown(_,_)),retractall(allSuspects(_)),
         retractall(allWeapons(_)),retractall(allRooms(_)), retractall(numPlayers(_)).

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
               read(Yours), inputCards(Yours), allSuspects(X), allWeapons(Y),allRooms(Z),append(X,Y,Temp),
               append(Temp,Z,AllCards),subtract(AllCards,Yours,NotYours), notYours(NotYours).

%checks if card is valid and adds it to our current database
notYours([]).
notYours([H|T]) :- valid(H,Type),assert(doesNotOwn(H,Type,1)), notYours(T).

%checks if card is valid and adds it to our current database
inputCards([H]) :- weapon(H), assert(not(H, weapon, 1)), doesNotHave(H,weapon,2).
inputCards([H]) :- suspect(H), assert(not(H, suspect, 1)),doesNotHave(H,suspect,2).
inputCards([H]) :- room(H), assert(not(H, room, 1)), doesNotHave(H,room,2).
inputCards([H|T]) :- weapon(H),assert(not(H, weapon, 1)),doesNotHave(H,weapon,2),inputCards(T).
inputCards([H|T]) :- suspect(H),assert(not(H, suspect, 1)),doesNotHave(H,suspect,2),inputCards(T).
inputCards([H|T]) :- room(H),assert(not(H, room, 1)),doesNotHave(H,room,2),inputCards(T).
inputCards([H|_T]) :- format("~w is not a card. Try Again.\n", H),
				              retractall(not(_,_,_)), retractall(doesNotOwn(_,_,_)), playerCards.

%console for actions
play :- (checkWin -> bagof(A,right(A),Z),format("SUGGEST THE FOLLOWING: ~w ~w ~w\n",Z),abort;true),
		(checkMaybes;true),
		 write("\nPlease choose a number :\n 1. View notebook \n 2. Record your move \n"),
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
			   format("\nYou should suggest ~w in the ~w with the ~w.\n\n",[Suspect,Room,Weapon]), sleep(1).

getSuspect(Suspect) :- (right(Suspect,suspect) -> true; unknownSuspects(Suspects), length(Suspects,SusLen), random(0,SusLen,SIndex), nth0(SIndex,Suspects,Suspect)).
getWeapon(Weapon) :- (right(Weapon,weapon) -> true;unknownWeapons(Weapons),length(Weapons,WepLen), random(0,WepLen,WIndex), nth0(WIndex,Weapons,Weapon)).
getRoom(Room) :- (right(Room,room) -> true;unknownRooms(Rooms),length(Rooms,RoomLen), random(0,RoomLen,RIndex), nth0(RIndex,Rooms,Room)).

%record your move and recording it
yourMove :- write("What did you ask to see from "), player(X,2), write(X), write("?\n"),
            write("Suspect? "), read(S), write("Weapon? "), read(W),
			      write("Room? "), read(R),room(R), weapon(W), suspect(S), write("Do they have it? (yes/no) "),
            read(Answer), have(Answer,[S,W,R],2).

%when the player you asked has one of the three cards
have(yes, List, PlayerNum) :- write("What card was it?"), read(Card), member(Card, List), valid(Card,Type),
							  assert(not(Card,Type,PlayerNum)), NextPlayer is PlayerNum + 1,
							  crossExtras(Card, Type,PlayerNum, NextPlayer), play.

%when the player you asked does not have one of the three cards
have(no, [S,W,R], PlayerNum) :- Next is PlayerNum+1,
								(doesNotOwn(W,weapon,PlayerNum) -> true; assert(doesNotOwn(W,weapon,PlayerNum))),
								(doesNotOwn(R,room,PlayerNum) -> true; assert(doesNotOwn(R,room,PlayerNum))),
								(doesNotOwn(S,suspect,PlayerNum) -> true; assert(doesNotOwn(S,suspect,PlayerNum))),
								(player(X, Next) -> write("Does "), write(X),
								write(" have it?"), read(NewAnswer), have(NewAnswer, [W,R,S], Next);
								write("No one has these three cards. \n\n"), play).


%asserts the cards that are not owned by the other players when shwon a card
crossExtras(_Card, _Type, End, End).
crossExtras(Card, Type, End, Current) :- player(_,Current),(doesNotOwn(Card,Type,Current) -> true;assert(doesNotOwn(Card,Type,Current))),
										 Next is Current + 1, crossExtras(Card,Type,End,Next).
crossExtras(Card, Type, End, _Current) :- crossExtras(Card,Type,End,1).

%prompt for other player's move and record
otherMove(Origin, Asked) :- player(X,Origin),player(Y, Asked),
                            format("What does ~w ask ~w?\n", [X,Y]),
                            write("Suspect? "),read(S),
                            write("Weapon? "), read(W),
                            write("Room? "), read(R),
                            format("Does ~w show ~w anything? (yes/no) ", [Y,X]),
                            read(Response), readResponse(Response,[S,W,R],Origin,Asked).

%if the other player is asking the user for a card
otherMove(Origin, _) :- player(X,Origin), format("What does ~w ask you?\n", X),
                        write("Suspect? "), read(S),
                        write("Weapon? "), read(W),
                        write("Room? "), read(R),
                        readResponse(_, [S,W,R], Origin, 1).

% pick which card to recommend to who
% shown(Card,PersonShownTo) keeps track of what we've shown to who
recommend([S,W,R],Origin) :- (shown(X,Origin), member(X,[S,W,R]) ->                   % if we've shown a card to this player before
                             format("\nRecommended that you show ~w.\n",X);        % show that same card
                             shown(Y,_), member(Y,[S,W,R]) ->                      % else if we've shown any card before,
                             format("\nRecommended that you show ~w.\n",Y),      % assert that same card if it's in the list
                             assert(shown(Y,Origin));
                             findall(X,not(X,_,1),YourCards),
                             intersection(YourCards,[S,W,R],[H|_T]),             % else show any card you want
                             format("\nRecommended that you show ~w.\n",H),      % if more than 1 possible,
                             assert(shown(H,Origin))).                           % show order: Suspect->Weapon->Place


%used when the user is asked if they have the cards
readResponse(_,[S,W,R],Origin,1) :- findall(X,not(X,_,1),YourCards),
                                    ((member(S,YourCards);member(W,YourCards);member(R,YourCards)) ->
                                    recommend([S,W,R],Origin), play;
                                    (Origin == 2 ->
                                    write("No one has these cards.\n\n"), play;
                                    player(X,Origin), player(Y,2),
                                    format("Does ~w show ~w anything? (yes/no) ", [Y,X]), read(Res),
                                    readResponse(Res,[S,W,R],Origin,2))).

%If the person being asked does have the cards
%maybeCount(Item,CurrCount,PlayerNum) - marks the cards a player MAY have
readResponse(yes, [S,W,R], _Origin, Asked) :- (maybeCount(_,CurrCount,Asked) ->
												NextCount is CurrCount + 1;
												NextCount is 1),
											 asserta(maybeCount(R,NextCount,Asked)),
											 asserta(maybeCount(W,NextCount,Asked)),
											 asserta(maybeCount(S,NextCount,Asked)).

%If the person being asked does not have the cards
readResponse(no,[S,W,R], Origin, Asked) :- (doesNotOwn(W,weapon,Asked) -> true;assert(doesNotOwn(W,weapon,Asked))),
                                           (doesNotOwn(S,suspect,Asked) -> true; assert(doesNotOwn(S,suspect,Asked))),
                                           (doesNotOwn(R,room,Asked) -> true; assert(doesNotOwn(R,room,Asked))),
										   Next is Asked+1,
                                           (Next == Origin -> write("No one has these cards.\n\n"), play; true),
                                           (player(X,Origin),player(Y,Next) ->
                                           format("Does ~w show ~w anything? (yes/no) ", [Y,X]),
                                           read(Response), readResponse(Response, [S,W,R], Origin, Next);
                                           readResponse(yes, [S,W,R], Origin, 1)).


%asserting cards that are owned by the player
doesNotHave(_Card, _Type, Player) :- not(player(_,Player)).
doesNotHave(Card, Type, Player) :- player(_,Player), (doesNotOwn(Card,Type,Player) -> true;assert(doesNotOwn(Card, Type, Player))),
                                   NewPlayer is Player + 1, doesNotHave(Card,Type,NewPlayer).

%test if an inputted card is valid
valid(Card,weapon) :- weapon(Card).
valid(Card,suspect) :- suspect(Card).
valid(Card,room) :- room(Card).

%prints the contents of the notebook
printNotebook :- nl,  % required else names will be printed starting at position 18 instead of 20
                      % when user imputs something, the next line is 'broken'
                      % test this by removing 'nl', running 'play' and then 'printNotebook' VS running 'printNotebook' on its own
                      % can force error on terminal: read(X),printNotebook.
                 forall(player(X,_Y), format("~20|~w  ", X)), nl,  % writes all the names of the players
                 findall(X, player(_,X), PlayerList),
                 forall(suspect(B), printPad(B,PlayerList,'')), write("\n"),
                 forall(weapon(A), printPad(A,PlayerList,'')), write("\n"),
                 forall(room(C), printPad(C,PlayerList,'')), write("\n").

%prints out the newly built string for each row in the table
printPad(Card, [], Str) :- format("~w~20|~w  ", [Card,Str]),nl.

%builds string to represent which player has what card
printPad(Card, [H|T], Str) :- player(Name,H),string_length(Name,NameLen),
                              (not(Card,_,H) -> string_concat(Str, "0 ", NewStr);
							                (doesNotOwn(Card,_,H)-> string_concat(Str, "X ", NewStr);
							                string_concat(Str, "  ", NewStr))),
							                fillSpace(NewStr,NameLen,FinStr), printPad(Card,T,FinStr).

fillSpace(String,0,String) :- !.
fillSpace(String,NameLen,FinStr) :- string_concat(String,' ',NewStr), NewLen is NameLen - 1, fillSpace(NewStr,NewLen,FinStr).

%checks if a winning solution has been found
checkWin :- retractall(right(_,_)),
			allWeapons(A1),findall(X1,not(X1,weapon,_),Z1),subtract(A1,Z1,New1),
			(retract(unknownWeapons(_));true),assert(unknownWeapons(New1)),
			allRooms(A2),findall(X2,not(X2,room,_),Z2),subtract(A2,Z2,New2),
			(retract(unknownRooms(_));true),assert(unknownRooms(New2)),
			allSuspects(A3),findall(X3,not(X3,suspect,_),Z3),subtract(A3,Z3,New3),
			(retract(unknownSuspects(_));true),assert(unknownSuspects(New3)),!,
			(length(New1,1) -> New1 = [LastWeapon],assert(right(LastWeapon,weapon)); true),
      (length(New2,1) -> New2 = [LastRoom],assert(right(LastRoom,room)); true),
      (length(New3,1) -> New3 = [LastSus],assert(right(LastSus,suspect)); true),
			(countTheX(A3,suspect);countTheX(A1,weapon);countTheX(A2,room)).

countTheX([]) :- false.
% recurse through list of Suspects/Weapons/Rooms (H) and counts how many X's there are
% if number of X's matches the number of players, we know that is the right answer
% the sort is to remove repeated asserts (should not happen, but just in case)
countTheX([H|T],Type) :- findall(X,doesNotOwn(H,_,X),List), numPlayers(Num), sort(List,NoDupes),
                            (length(NoDupes,Num) -> assert(right(H,Type)); countTheX(T,Type)).


checkMaybes :- forall(weapon(A), elimMaybes(A)),
               forall(suspect(B), elimMaybes(B)),
               forall(room(C), elimMaybes(C)),
			   findall(X, player(_,X), PlayerList),
               maybe2known(PlayerList).

% eliminates items with a MAYBE and a NOT mark, since it can't be both
elimMaybes(Item) :- (doesNotOwn(Item,_,PlayerNum), maybeCount(Item,_,PlayerNum) ->
						retract(maybeCount(Item,_,PlayerNum));true).

% after eliminating places with both an NOT and a MAYBE,
% check to see if there is only a single instance of a particular Maybe count
% if there is, you know that they have that card, hence you go from 'maybe' to 'known'
maybe2known([]).
maybe2known([PlayNumH|PlayNumT]) :- findall(Counts,maybeCount(_,Counts, PlayNumH),List), length(List,ListLen),
              (ListLen > 0 ->
						       msort(List,Sorted), Sorted = [H|T], removeDuplicates(H,T,EndList),
              markKnown(EndList,PlayNumH);true), maybe2known(PlayNumT).


% will remove all elements that appear more than once
removeDuplicates(X,[],[X]) :- !.
% if only 2 elements in list and they're the same, return empty list
removeDuplicates(H,[H],[]) :- !.
% if first element in list matches second element, remove all instances of that element
removeDuplicates(H,[H|T],EndList) :- (delete(T,H,[NewH|NewT]) ->
                                        removeDuplicates(NewH,NewT,EndList);
                                        removeDuplicates(1,[1],EndList)),!.
% else, recurse on list
removeDuplicates(H,[NewH|NewT],[H|Rest]) :- removeDuplicates(NewH,NewT,Rest).

markKnown([],_).
markKnown([H|T], PlayerNum) :- maybeCount(Card,H,PlayerNum), valid(Card,Type),
                               retract(maybeCount(Card,H,PlayerNum)),assert(not(Card,Type,PlayerNum)),
                               NextPlayer is PlayerNum + 1, crossExtras(Card, Type,PlayerNum, NextPlayer),
                               markKnown(T,PlayerNum).
