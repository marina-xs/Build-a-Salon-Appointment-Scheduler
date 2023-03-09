#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
echo -e "\n~~~~~ My salon ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"
MAIN_MENU(){
  #SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services")
  #echo "$SERVICES_OFFERED"
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "$($PSQL "SELECT service_id, name FROM services")" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  #get the name of the service 
  #if you put this line after the whole case statement, it will not be executed!!!!
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  case $SERVICE_ID_SELECTED in
    1 | 2 | 3 | 4 | 5) RESERVE ;;
    q) EXIT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?";;
  esac
}

RESERVE(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #check if it is a new customer, since later we will use the customer name, just get it here
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
  #ask for the name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
  #add new customer
    ADD_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  #get cutomer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #ask for the time
  echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #add into appointments table
  RESERVE_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  EXIT
}

#该选项自动起到了退出程序的作用,可能是自带了exit关键字？
EXIT() {
  echo -e "\nSee you soon!\n"
}
MAIN_MENU
