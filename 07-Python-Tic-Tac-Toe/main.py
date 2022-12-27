import random

def game_display(board):
    print(f'       |       |   ')
    print(f'   {board[7]}   |   {board[8]}   |   {board[9]} ')
    print(f'       |       |   ')
    print(f'-----------------------')
    print(f'       |       |   ')
    print(f'   {board[4]}   |   {board[5]}   |   {board[6]} ')
    print(f'       |       |   ')
    print(f'-----------------------')
    print(f'       |       |   ')
    print(f'   {board[1]}   |   {board[2]}   |   {board[3]} ')
    print(f'       |       |   ')

def player_input():
    player1 = ''
    player2 = ''
    print('Welcome to Tic Tac Toe!')

    while player1 not in ['X', 'O']:
        player1 = input("Player 1: Do you want to be 'X' or 'O'?").upper()
        if player1 not in ['X', 'O']:
            print(f"I'm sorry, '{player1}' is NOT a valid choice. Please choose 'X' or 'O'")
    if player1 == 'X':
        player2 = 'O'
    else:
        player2 = 'X'
    print(f'Player 1: {player1}')
    print(f'Player 2: {player2}')
    return (player1, player2)

def place_marker(board, marker, position):
    board[position] = marker
    print('\n'*100)
    game_display(board)

def win_check(board, marker):
    if board[1] == marker and board[2] == marker and board[3] == marker:
        return True
    elif board[4] == marker and board[5] == marker and board[6] == marker:
        return True
    elif board[7] == marker and board[8] == marker and board[9] == marker:
        return True
    elif board[1] == marker and board[4] == marker and board[7] == marker:
        return True
    elif board[2] == marker and board[5] == marker and board[8] == marker:
        return True
    elif board[3] == marker and board[6] == marker and board[9] == marker:
        return True
    elif board[1] == marker and board[5] == marker and board[9] == marker:
        return True
    elif board[3] == marker and board[5] == marker and board[7] == marker:
        return True
    else:
        return False

def choose_first():
    first = random.randint(0,100)
    if first % 2 == 0:
        print("Player 1 will go first")
        return "1"
    else:
        print("Player 2 will go first")
        return "2"

def space_check(board, position):
    if board[position] not in ['X','O']:
        return True
    else:
        return False

def full_board_check(board):
    for i in board:
        if i not in ['#','X','O']:
            return False
        else:
            continue
    return True

def player_choice(board):
    position = 0
    available = False
    check_list = [1,2,3,4,5,6,7,8,9]

    while position not in check_list or available == False:
    #while available == False:
        position = int(input('Which position would you like to choose? (1-9): '))
        if position in check_list:
            available = space_check(board, position)

    if available == True:
        return position

def replay():

    play_again = input("Would you like to play again? 'Yes' or 'No': ").upper()
    if play_again == 'YES':
        return True
    else:
        print('Goodbye!')
        return False

def tic_tac_toe():
    # Variables
    my_board = ['#',1,2,3,4,5,6,7,8,9]
    player1, player2 = player_input()
    turn = 0
    winner = False
    full_board = False
    play_again = False

    # Display Blank Tic-Tac-Toe Board
    game_display(my_board)

    # Assign which player will go First
    first_player = choose_first()
    if first_player == '1':
        turn = 1
    else:
        turn = 2

    # Beginning the Game
    while winner == False and full_board == False:

        position = player_choice(my_board)

        if turn == 1:
            place_marker(my_board,player1,position)
            winner = win_check(my_board,player1)
            full_board = full_board_check(my_board)
            turn = 2
        else:
            place_marker(my_board,player2,position)
            winner = win_check(my_board,player2)
            full_board = full_board_check(my_board)
            turn = 1

    # Print out message to winner
    if winner == True and turn == 2:
        print("Congratulations Player 1!")
    elif winner == True and turn == 1:
        print("Congratulations Player 2!")

    # Message in event of a draw
    if full_board == True and winner == False:
        print("The Game has ended in a Draw.")

    # Ask players if they want to play again
    play_again = replay()

    # Rerun program or Quit
    if play_again == True:
        tic_tac_toe()

tic_tac_toe()


