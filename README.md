# Clue-Helper
###Authors: Va Vong, Henry Jue

####Purpose:
    This program is designed to be used by people who play the classic board games Clue. Our program provides an interactive notepad, in which the user can record the flow of the game and all known information.

###Usage:
    First, the user must open the SWI-Prolog environment with the command "swipl," when they are in the directory where clue.pl resides and from here on all commands run in the prolog environment requires a period at the end. Then, the user must input the "[clue]." in order to load the program into the prolog environment. To start the program, the user then must run the command "clue.", which starts the setup of the game. The program will then prompt the user for the number of players, the player names, whether or not it is the default version of this game, and if not, the names for all the suspects, weapons and rooms.
    The format of the input of the number of players resembles the commands used earlier. However, the number must be between 3 and 6 followed by a period. But all inputs that are more than one item, such as the input of player names, requires that the list of names be within square brackets, the items in the list are separated by commas, and the end of the list must once again be ended with a period. When playing the user's own version of the game, the number of suspects, weapons, and rooms will not be verified to allow for flexibility in the possibilities.
    After inputting, all the information regarding the logistics of the game, the user will be prompted to list the cards in their hand. This will allow the program to start collecting useful data and be able to create a visual representation of known information.
    Once all basic information is gathered, the user will be presented with a menu of options and prompted to make a choice from the following :
        1. View notebook
        2. Record your move
        3. Record other player's move
        4. Give suggestion
        5. Quit
    A choice is made by inputting the number associated with the choice followed by a period. The first choice will print a visual representation of all the known information to the screen. An "X" indicates a player does not have the card, an "O" denotes that a player does have that card, and a blank means we do not know who has the card.
    Inputting "2." will make the program prompt the user for the suspect, weapon, and room that the user is asking of the player that comes after them in the original list of players. Next, the program will ask if the player that was asked has the card or not. If the program is told "no.", then it will ask the next player until it makes its way all the way back to the user. If the program ever receives a "yes.", then it will ask which card was shown to the user. All the information gathered, such as who does not have the cards specified, will be recorded onto the notebook and can be viewed with the "View notebook" option.  If the program has gathered enough information to solve the murder, then, the next time it returns to the menu, it will inform the user of the winning accusation.
    The third option is very similar, but instead it will prompt the user for the name of the person making the accusation. After that the program will ask if the player that comes after the original asker has these cards. The program will continue to cycle through the players as it receives "no."'s and until it receives a "yes."
    The fourth option will tell the program to suggest a possible accusation to make on the user's next turn. This information is based off all the cards the user does not know anything about. If the answer in a certain category is known, the suggestion will then come from a pool of your own cards plus the known answer card.
    Finally, the last possible choice is to quit the prompt, however this does not quit the current game. The game can be returned to simply by inputting the "play." command, and the user console will return to the screen. To start a new game, simply use the "clue." command again, and all previous information will be removed from the notebook.

###Additional Features
    There is an invisible feature for the notepad. If non-player-character1(NPC1) asked NPC2 for something and is shown a card, our program marks NPC2's notepad (invisibally) with a "maybe" for all three cards. If at any point 2/3 of the "maybe"s for a certain turn is eliminated (this is done automatically if an X occupies the same location as a "maybe"), the program will automatically check that last "maybe" as a "known".    
    When somebody asks you for a card, the program first checks if you have shown that person a card before. If yes, then it recommends you show that same card. If you haven't, it then checks whether or not you've shown ANY of the 3 cards before. If yes, it recommends that card. If not, it will recommend you show any card in the order of Suspect->Weapon->Room, since Room is the most valuable.

###Bugs and Missing Features:
    Much of the program requires that the user inputs correct options. but if the program does crash due to improper input, simply input the "play." command, and you will be returned to the main menu to continue playing. At times, you may have incorrect database entries, but it's chill bro.
    Any dumb inputs will likely crash our program. It can tolerate 3 +- 1 instances of this. After that, it's fair game. You've been warned.
