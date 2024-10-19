#!/bin/bash

#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
    exit 0
fi

# Capitalize the first letter of the input for the symbol and name
input=$(echo "$1" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')

# Function to query the database for the element information
get_element_info() {
    local input="$1"
   if [[ "$input" =~ ^[0-9]+$ ]]; then
        # If input is a number, query by atomic_number
        $PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
        FROM elements e
        JOIN properties p ON e.atomic_number = p.atomic_number
        JOIN types t ON p.type_id = t.type_id
        WHERE e.atomic_number = $input;"
    else
        # If input is not a number, query by symbol or name
        # Capitalize the first letter of the input for symbol and name comparison
        local capitalized_input=$(echo "$input" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
        
        $PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
        FROM elements e
        JOIN properties p ON e.atomic_number = p.atomic_number
        JOIN types t ON p.type_id = t.type_id
        WHERE e.symbol = '$capitalized_input' OR e.name ILIKE '$capitalized_input';"
    fi
}

# Store the result of the query
result=$(get_element_info "$input")

if [ -z "$result" ]; then
    echo "I could not find that element in the database."
else
    # Format the output
    IFS='|' read -ra fields <<< "$result"
    atomic_number=$(echo "${fields[0]}" | xargs)
    name=$(echo "${fields[1]}" | xargs)
    symbol=$(echo "${fields[2]}" | xargs)
    atomic_mass=$(echo "${fields[3]}" | xargs)
    melting_point=$(echo "${fields[4]}" | xargs)
    boiling_point=$(echo "${fields[5]}" | xargs)
    type=$(echo "${fields[6]}" | xargs)

    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi