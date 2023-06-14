#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~ SALON MOES' ~~"

# MAIN_MENU
MAIN_MENU() {
  # If there is not previous answer (When we just enter to the "shop"):
if [[ -z $1 ]]
then
echo -e "\nWelcome! How may I help you today?"

  # When coming back from other section:
  else
  echo -e "\n$1"
  echo -e "\nWhat else can we do for you?"
fi

  # Menu display (Every service we have available):
echo "1) haircut"
echo "2) hair color"
echo "3) perm"
echo "4) hair style"
echo "5) hair trim"
echo "6) Exit"

# These prompts are not shown; it is just so we can choose a service from the ones that do actually pop up above
read MAIN_MENU_SELECTION

case $MAIN_MENU_SELECTION in
# /////
  # All of these options lead you to the same place, although the words enclosed with the quotation marks
  #  leads us exactly where the service is at within the psql prompt (we'll see more about that later):
# /////
  1) SERVICE "haircut" ;;
  2) SERVICE "hair color" ;;
  3) SERVICE "perm" ;;
  4) SERVICE "hair style" ;;
  5) SERVICE "hair trim" ;;
  6) EXIT ;;
  # This one shows the menu again when a wrong option is entered:
  *) MAIN_MENU "Please enter a valid option." ;;
  esac
}


SERVICE() {
  # The words in the quotation marks mentioned before are pulled out with the "$1" symbol since "$1" 
  # means the previous answer entered by the user. For example if a user entered number 3 for the options above
  # that would indicate that they are choosing "3) SERVICE "perm" ;;" meaning that "$1" in this case is "perm".
SERVICE_NAME=$1  
# After the previous answer, we pull out the service_id from the database using the variable which was
#  attached the "$1":
SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_NAME'")

# Here we start asking the "Customer" what their number is so start looking for it:
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# We check if the number is valid by doing a regex combination inside a while loop that allowes us check 
# if the phone number contains only number and dash symbols
while [[ ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]
do
echo "Please insert a valid number."
read CUSTOMER_PHONE
done

# When the phone number goes through, pull out the name of the caller if they are already included in the database
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If customer name is not found:
if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME

# After asking for thei name we now insert it into the database:
# There is no need to insert it when the costumer is found since they already exist in the database.
INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# The name gets cleaned up with the regex since for some reason a space pops up before the name
CLEANED_NAME=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')

# We get the customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# We need the time so we attach it to the appointment table 
echo -e "\nWhat time would you like your $SERVICE_NAME, $CLEANED_NAME?"
read SERVICE_TIME

# Making sure the time is correctly entered by the customer
while [[ ! $SERVICE_TIME =~ ^[0-9a-z:]+$ ]]
do
# We specify with and example how the number should be
echo "Please insert a valid time. Ex: 3:45pm"
read SERVICE_TIME
done

# After the time goes through we insert it into the appointments table along the service id which we found at the top of the function
NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
# NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$TIME')")

# Everything goes through, the customer goes back to the menu:
MAIN_MENU "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CLEANED_NAME."
}


# EXIT
EXIT() {
# When the customer decides exiting the "Shop":
echo -e "\nThank you for stopping in.\n"
}

# We call only the function we want to run by defult
MAIN_MENU
