#!/bin/bash

PSQL="psql --username=freecodecamp dbname=salon -c";

echo -e "\n~~~ Beauty salon ~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo $1
  else
    echo -e "Welcome to Beauty Salon. How can I help you?\n"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read ID BAR NAME
  do
    if [[ $ID =~ ^[0-9]+$ ]]
    then
      echo "$ID) $NAME"
    fi
  done
  READ_SERVICE

}
READ_SERVICE(){
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_RECORD=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_RECORD=$(echo "$SERVICE_RECORD" | sed '1d;2d;$d')
    if [[ -z $SERVICE_RECORD ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      GET_CUSTOMER
    fi
  fi
}

GET_CUSTOMER(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_RECORD=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_RECORD=$(echo "$CUSTOMER_RECORD" | sed '1d;2d;$d' | sed -E 's/^ *| *$//g')
  if [[ -z $CUSTOMER_RECORD ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $INSERT_CUSTOMER != "INSERT 0 1" ]]
    then
      echo $INSERT_CUSTOMER
    fi
  fi
  ARRANGE_APPOINTMENT
}

ARRANGE_APPOINTMENT(){
  CUSTOMER_RECORD=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_RECORD=$(echo "$CUSTOMER_RECORD" | sed '1d;2d;$d' | sed -E 's/^ *| *$//g')
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_RECORD'")
  CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed '1d;2d;$d' | sed -E 's/^ *| *$//g')
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_RECORD")
  SERVICE_NAME=$(echo "$SERVICE_NAME" | sed '1d;2d;$d' | sed -E 's/^ *| *$//g')
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_RECORD, $SERVICE_RECORD, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
