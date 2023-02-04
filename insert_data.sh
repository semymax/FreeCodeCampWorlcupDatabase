#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Deleting data on the tables
echo "$($PSQL "TRUNCATE teams, games")"

# making easier to repeat getting ids
get_id() {
  echo "$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")"
}

cat games.csv | \
while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ $round != "round" ]] ; then
    for team in "$winner" "$opponent" ; do
      # get team_id
      TEAM_ID=$(get_id "$team")
      # if team_id not found
      if [[ -z "$TEAM_ID" ]] ; then
        if [[ $($PSQL "INSERT INTO teams(name) VALUES('$team')") == "INSERT 0 1" ]] ; then
        echo -e "$team inserted into teams.\n"
        fi
      fi
    done

    # get winner_id
    WINNER_ID=$(get_id "$winner")

    # get opponent_id
    OP_ID=$(get_id "$opponent")

    # insert game data
    if [[ $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OP_ID, $winner_goals, $opponent_goals)") == "INSERT 0 1" ]] ; then
      echo -e "Match $winner v $opponent inserted into games.\n"
    fi

  fi
done
