# Clue-Helper
###Authors: Va Vong, Henry Jue

####Purpose: 
    This program is designed to be used by people who play the classic baord games Clue. Our porgram provides an interactive notepad, in which the user can record the flow of the game and all known information.

###Useage: 
    First, the user must open the SWI-Prolog environment with the command "swipl," when they are in the directory where clue.pl resides and from here on all commands run in the prolog environment requires a period at the end. Then, the user must input the "[clue]." in order to load the program into the prolog environment. To start the program, the user then must run the command "clue.", which starts the setup of the game. The program will then prompt the user for the number of players, the player names, whether or not it is the default version of this game, and if not, the names for all the suspects, weapons and rooms. 
    The format of the input of the number of players resembles the commands used earlier. However, the number must be between 3 and 6 followed by a period. But all inputs that are more than one item, such as the input of player names, requires that the list of names be within square brackets, the items in the list are seperated by commas, and the end of the list must once again be ended with a period. When playing the user's own version fo the game, the number of suspects, weapons, and rooms will not be verified to allow for flexibility in the possibilities. 
    After inputting, all the information regarding the logistics of the game, the user will be prompted to list the cards in their hand. This will allow the program to start collecting useful data and be able to create a visual representation of known informatin.
    Once all basic information is gathered, the user will be presented with a menu of options and prompted to make a chocie from the following :
        1. View notebook
        2. Record your move
        3. Record other player's move
        4. Give suggestion
        5. Quit
    A choice is made by inputting the number associated with the choice followed by a period. The first choice will print a visual representation of all the known information to the screen. An "X" indicates a player does not have the card, an "O" tells denotes that a player does have that card, and a blank means we do not know who has the card. 
    Inputting "2." will make the program prompt the user for the suspect, weapon, and room that the use ris asking of the player that comes after them in the original list of players. Next, the program will ask if the player that was asked has the card or not. If the porgram is told "no.", then it will ask the next player until it makes its way all the way back to the user. If the program ever receives a "yes.", then it will ask which card was shown to the user. All the information gathered, such as who does not have the cards specified, will be recorded onto the notebook and can be viewed with the "View notebook" option.  If the program has gathered enough information to solve the murder, then, the next time it returns to the menu, it will inform the user of the winning accusation.
    The third option is very similar, but instead it will prompt the user for the name of the person making the accusation. After that the program will ask if the player that comes after the original asker has these cards. The program will continue to cycle through the players as it receives "no."'s and until it receives a "yes." 
    The fourth option will tell the program to suggest a possible accusation to make on the user's next turn. This information is based off all the cards the user does not know anything about. 
    Finally, the last possible choice is to quit the prompt, however this does not quit the current game. The game can be returned to simply by inputting the "play." command, and the user console will return to the screen. To start a new game, simply use the "clue." command again, and all previous information will be removed from the notebook.


###Bugs and Missing Features: 
    Much of the program requires that the user inputs correct options. For example, players, suspects,weapons, and rooms must be spelled correctly. 