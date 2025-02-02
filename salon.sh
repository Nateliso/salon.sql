#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ BRETT'S GRAND SALON ~~~~~\n"
echo -e "Welcome to Brett's Grand Salon! What service would you like:\n"

# Display services
MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Handle customer input and make an appointment
MAKE_APPOINTMENT() {
  # Display the menu
  MAIN_MENU

  # Take response
  read SERVICE_ID_SELECTED

  # Validate input
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\n⚠️ Invalid selection. Please enter a valid service number."
    MAKE_APPOINTMENT
    return
  fi

  # Handle customer's name and phone number
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nIt looks like you're a new customer. Please enter your name:"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Get appointment time
  echo -e "\nEnter appointment time in HH:MM (e.g., 10:30): "
  read SERVICE_TIME

  $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
  
  # Final confirmation message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Start the process
MAKE_APPOINTMENT
