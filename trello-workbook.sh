#!/usr/bin/env sh

set -x
# uncomment when I publish
USER_NAME=$1
BOARD_NAME=$2
FILE_NAME=$3
START_DATE=$4
TIMEZONE_OFFSET="+09"
DUE=$(date -j -f '%Y-%m-%d' $START_DATE "+%Y-%m-%dT23:59:59")

# Get the boards' IDs from the given username
RESPONSE=$(curl --request GET \
  --url "https://api.trello.com/1/members/$USER_NAME/boards?fields=id,name&key=$API_KEY&token=$API_TOKEN")

# Create a new board
BOARD_NAME_ENCODED=$(printf "$BOARD_NAME" | jq -srR @uri)
RESPONSE=$(curl --request POST \
  --url "https://api.trello.com/1/boards/?name=$BOARD_NAME_ENCODED&key=$API_KEY&token=$API_TOKEN")
BOARD_ID=$(jq -r '.id' <<< $RESPONSE)

# Read the list names from the file
LIST_NAMES=$(awk 'BEGIN { FS="." } { arr[$1]++ } END{ for (a in arr) print a }' "$FILE_NAME" | sort -n)
# Create the lists
for l in $LIST_NAMES
do
  RESPONSE=$(curl --request POST \
    --url "https://api.trello.com/1/lists?name=$l&idBoard=$BOARD_ID&pos=bottom&key=$API_KEY&token=$API_TOKEN")
  LIST_ID=$(jq -r '.id' <<< $RESPONSE)
  # Read the card names of the list from the file
  CARD_NAMES=$(awk -v pat=$l 'BEGIN { FS="." } $1==pat { arr[$2]++ } END{ for (a in arr) print a}' "$FILE_NAME" | sort -n)
  # Create the cards
  while read -r c
  do
    CARD_NAME_ENCODED=$(printf "$c" | jq -srR @uri)
    RESPONSE=$(curl --request POST \
      --url "https://api.trello.com/1/cards?name=$CARD_NAME_ENCODED&idList=$LIST_ID&due=$DUE&pos=bottom&key=$API_KEY&token=$API_TOKEN")
    DUE=$(date -v+1d -jf '%Y-%m-%dT%H:%M:%S' "$DUE" '+%Y-%m-%dT%H:%M:%S')
  done <<< "$CARD_NAMES"
done

set +x