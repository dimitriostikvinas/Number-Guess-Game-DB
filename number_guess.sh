#!/bin/bash
# Number Guesser Game
# Tested
# Refactor
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo -e "\nEnter your username:"
  fi
  read USERNAME
  DISPLAY $USERNAME
  echo "Guess the secret number between 1 and 1000:"
  RANDOM_NUMBER_GUESSER $USERNAME
}

DISPLAY(){
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$1'")

  if [[ -z $USER_ID ]]
  then
    USER_INSERT_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$1')")
    if [[ -z $USER_INSERT_RESULT ]]
    then
      MAIN_MENU "Your input is invalid. Try a name with less than 22 characters."
    else
      echo "Welcome, $1! It looks like this is your first time here."
    fi
  else
    USERNAME_JOIN_RESULT=$($PSQL "SELECT MIN(g.number_of_guesses_to_win), COUNT(*) FROM users AS u INNER JOIN games AS g USING(user_id) WHERE u.name='$1'")
    if [[ $USERNAME_JOIN_RESULT ]]
    then
      echo $USERNAME_JOIN_RESULT | while IFS="|" read BEST_GAME GAMES_PLAYED
      do
        echo "Welcome back, $1! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      done
    fi
  fi
}

RANDOM_NUMBER_GUESSER(){
  if [[ -z $NUMBER_OF_GUESSES ]]
  then
    NUMBER_OF_GUESSES=0
  fi

  if [[ $1 ]]
  then
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$1'")
    if [[ -z $USER_ID ]]
    then
      echo "User wasn't found"
      exit 1
    fi
  fi

  while true
  do
    read INPUT
    if [[ ! $INPUT =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $INPUT -gt $RANDOM_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES++ ))
      echo "It's lower than that, guess again:"
    elif [[ $INPUT -lt $RANDOM_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES++ ))
      echo "It's higher than that, guess again:"
    else
      (( NUMBER_OF_GUESSES++ ))
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(number_of_guesses_to_win, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID)")
      if [[ -z $INSERT_GAME_RESULT ]]
      then
        echo "Couldn't insert game into database"
      fi
      break
    fi
  done
}

# Initialize random number and start main menu
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
MAIN_MENU
