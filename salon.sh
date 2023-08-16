#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align -t -c"

MAIN_MENU() {
  echo -e "\n Please pick a service"
  echo "$($PSQL "SELECT * FROM services")" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo -e "\n$SERVICE_ID) $SERVICE_NAME"
  done
}

echo -e "\n~~~ Welcome to the Salon ~~~"

MAIN_MENU

read SERVICE_ID_SELECTED
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
  MAIN_MENU
else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nPlease tell me your name also"
    read CUSTOMER_NAME
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  if [[ -z $CUSTOMER_ID ]]
  then
    echo "Still no customer"
  else
    echo -e "At what time would you like to schedule your appointment?"
    read SERVICE_TIME
    CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $CREATE_APPOINTMENT ]]
    then
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
fi
