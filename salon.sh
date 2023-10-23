#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo How may i help you? 
  fi

  SERVICES=$($PSQL"SELECT * FROM services ORDER BY service_id")
  # print the services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME" | sed 's/\b\([a-z]\)/\u\1/g'
  done
  read SERVICE_ID_SELECTED

  # check if option is a service
  SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SELECTED_SERVICE ]]
  then
    MAIN_MENU "Please enter a valid service"
  else

  # prompt user to enter phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # check if customer exists in database
  CUSTOMER_NAME=$($PSQL"SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    # if not prompt user to enter name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
    # prompt user for appointment time
    echo -e "\nWhen do you want your appointment?"
    read SERVICE_TIME
    # get customer ID to schedule
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # insert appointment into appointments
    INSERT_TIME_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
    # get selected service name
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # display feedback
    CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed 's/\b\([a-z]\)/\u\1/g')
    echo -e "\nI have put you down for a$SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU