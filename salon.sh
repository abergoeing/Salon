#!/bin/bash
# PSQL QUERY FUNCTION
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# welcome users and display available services, ask to select a service
echo -e "\n~~~~~ B-Glam Hair and Nail Salon ~~~~~\n"
echo -e "\nWelcome to B-Glam, how can we help you today?"
# create MAIN_MENU function
MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # get service selected
  read SERVICE_ID_SELECTED
  # if input not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu with argument
    MAIN_MENU "That is not a valid option." 
  fi
  # if input not in list
  LAST_SERVICE=$($PSQL "SELECT MAX(service_id) FROM services")
  if (( $SERVICE_ID_SELECTED > $LAST_SERVICE ))
  then
    # send to main menu with argument
    MAIN_MENU "Please select a number from the list."
  fi
}
MAIN_MENU
# get customer phone number
echo "What is your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# if not in customers table
if [[ -z $CUSTOMER_NAME ]]
then
  # get customer name
  echo -e "\nI don't have that phone number. What is your name?"
  read CUSTOMER_NAME
  # add customer to customers table
  INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# ask for time
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')
echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $(echo $CUSTOMER_NAME | sed 's/ //')?"
read SERVICE_TIME

# get customer_id info from customers table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# schedule service
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# say goodbye
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //')."
