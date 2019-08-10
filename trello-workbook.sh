#!/usr/bin/env sh

# uncomment when I publish
# USER_NAME=$1
# BOARD_NAME=$2
set -x
# Get the boards' IDs from the given username
RESPONSE=$(curl --request GET \
  --url "https://api.trello.com/1/members/$USER_NAME/boards?fields=id,name&key=$API_KEY&token=$API_TOKEN")

# If there is an existing board of name $BOARD_NAME, then use it.
# Otherwise, create a new one.
BOARD_ID=$(jq '.[] | select (.name == $board_name)' --arg board_name "$BOARD_NAME" <<< $RESPONSE)
if [ -z "$BOARD_ID" ]
then
    echo "There is no board of name $BOARD_NAME"
    BOARD_NAME_ENCODED=$(echo "$BOARD_NAME" | jq -srR @uri)
    curl --request POST --url "https://api.trello.com/1/boards/?name=$BOARD_NAME_ENCODED&key=$API_KEY&token=$API_TOKEN"
    echo "Created board: $BOARD_NAME"
    RESPONSE=$(curl --request GET \
        --url "https://api.trello.com/1/members/$USER_NAME/boards?fields=id,name&key=$API_KEY&token=$API_TOKEN")
    BOARD_ID=$(jq '.[] | select (.name == $board_name)' --arg board_name "$BOARD_NAME" <<< $RESPONSE)
else
    echo "Found an existing board of name $BOARD_NAME"
fi

set +x
# Create a card
# CARD_NAME=test
# CARD_POS=bottom
# TIMEZONE_OFFSET="+09" # JST
# ID_LIST=

# DUE="2017-12-12T17:00:00.000$TIMEZONE_OFFSET"
# curl --request POST \
#   --url 'https://api.trello.com/1/cards?idList=idList&keepFromSource=all&key=yourApiKey&token=yourApiToken'