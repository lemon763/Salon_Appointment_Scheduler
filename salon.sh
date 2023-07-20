#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n~~~ My Salon ~~~\n'
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [0-9]) BOOK_MENU ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac
}
  BOOK_MENU(){
    SERVICE_CHOSEN=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_CHOSEN ]]
    then
		MAIN_MENU "I could not find that service. What would you like today?"
    fi
	echo -e "\nWhat's your phone number?"
	read CUSTOMER_PHONE
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
	if [[ -z $CUSTOMER_ID ]]
	then
		echo -e "\nI don't have a record for that phone number, what's your name?"
		read CUSTOMER_NAME
		INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
	else
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
	fi
	echo -e "\nWhat time would you like your $SERVICE_CHOSEN, $CUSTOMER_NAME?"
	read SERVICE_TIME
	INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
	echo -e "I have put you down for a $SERVICE_CHOSEN at $SERVICE_TIME, $CUSTOMER_NAME."
}
MAIN_MENU
