#!/bin/bash
# URCade Custom Collection Creator
# Author: Tarso Galvão - Version: 1.0 Date: Fri Jan 26 10:45:05 AM -03 2024

#------------------------------- CONFIGS -----------------------------------------
# Set the default search folder (Change this to the path of your roms root folder)
search_folder="$HOME/RetroPie/roms"
# Set the default custom collections folder (Change this to the path of your collections root folder)
destination_folder="$HOME/.emulationstation/collections/"
#---------------------------------------------------------------------------------

#------------------------------ FUNCTIONS ----------------------------------------
# Function to display a message and optionally return to the main form menu
exit_with_message() {
    local message="$1"
    local return_to_menu="$2"

    if [ -n "$return_to_menu" ]; then
        dialog --backtitle "URCade Custom Collection Creator" --msgbox "$message" 8 40
        show_dialog_menu
    else
        clear
        echo "$message"
        exit 0
    fi
}

# Function to save the list to a file
save_list() {
    mv "$result_file" "$collection_name_path"
    echo "Search results have been saved to: $collection_name_path"
}

# Function to display the dialog menu
show_dialog_menu() {
    dialog --backtitle "URCade Custom Collection Creator" \
           --title "URCade Custom Collection Creator" \
           --ok-label "Search" \
           --cancel-label "Exit" \
           --form "Configure your search:" 10 60 0 \
           "Search Folder:" 1 1  "$search_folder" 1 18 40 0 \
           "Search Term:" 2 1 "$search_term" 2 18 40 0 \
           "Collection Name:" 3 1 "$collection_name" 3 18 40 0 \
           2> "$temp_file"

    # Check if the user pressed 'Exit'
    [ $? -eq 1 ] && exit_with_message "Exiting..."

    # Read values from the temporary file
    search_folder=$(sed -n 1p "$temp_file")
    search_term=$(sed -n 2p "$temp_file")
    collection_name=$(sed -n 3p "$temp_file")

    # Remove temporary file
    rm "$temp_file"

    # Check if search folder exists
    if [ ! -d "$search_folder" ]; then
        exit_with_message "Error: $search_folder does not exist. Please enter a valid folder." "true"
    fi

    # Check if form fields are not empty
    if [ -z "$search_folder" ] || [ -z "$search_term" ] || [ -z "$collection_name" ]; then
        exit_with_message "Error: All fields are required. Please enter valid values." "true"
    fi
}

# Function to display the result in a scrollable window
show_result_window() {
    dialog --backtitle "URCade Custom Collection Creator" \
           --title "Search Results" \
           --textbox "$result_file" 20 120
}

# Function to ask for confirmation
ask_for_confirmation() {
    dialog --backtitle "URCade Custom Collection Creator" \
           --yesno "Do you want to save the list to \"$collection_name_path\"?" 7 50
}

# Function to ask if the user wants to search again
ask_to_search_again() {
    dialog --backtitle "URCade Custom Collection Creator" \
           --yesno "Create another collection?" 7 50
}

# Main function to perform the search
perform_search() {
    # Use find to search for files and store them in an array
    files=()
    while IFS= read -r -d $'\0' file; do
        files+=("$file")
    done < <(find "$search_folder" -type d -name 'media' -prune -o -type f -iname "*$search_term*" -print0)

    # Output the list to a temporary file
    result_file=$(mktemp /tmp/search_result.XXXXXX)
    printf "%s\n" "${files[@]}" > "$result_file"
}
#---------------------------------------------------------------------------------

#------------------------------ MAIN LOOP ----------------------------------------
# Main loop
while true; do
    # Check if the search term and output file name are provided as command-line arguments
    if [ "$#" -eq 0 ]; then
        # Temporary file to store dialog input
        temp_file=$(mktemp /tmp/search_config.XXXXXX)

        # Display dialog menu
        show_dialog_menu
    elif [ "$#" -eq 2 ]; then
        search_term="$1"  # Use the first command-line argument as the search term (partial match)
        collection_name="$2"  # Use the second command-line argument as the output file name

        # Prepend "custom-" to the output file name
        custom_collection_name="custom-$collection_name"

        # Define the output file path
        collection_name_path="${custom_collection_name}.cfg"

        # Check if the search folder exists
        if [ ! -d "$search_folder" ]; then
            echo "Error: The search folder does not exist. Please enter a valid path in search_folder='' inside this script."
            exit 0
        fi

        # Perform the search
        perform_search

        # Check if the search results are empty
        if ! grep -q . "$result_file"; then
            echo "No results were found for the given search term."
            exit 0
        fi


        # Clear the screen and save the file
        save_list

        exit 0
    else
        echo "ERROR: Invalid number of arguments."
        echo "Usage:   $0 <search_term> <collection_name>"
        echo "Example: $0 'Mario kart' mariokart  =>  custom-mariokart.cfg"
        echo "Or use with no args to enter interactive menu."
        exit 0
    fi

    # Prepend "custom-" to the output file name
    custom_collection_name="custom-$collection_name"

    # Define the output file path
    collection_name_path="${custom_collection_name}.cfg"

    # Perform the search
    perform_search

    # Display the result in a scrollable window
    show_result_window

    # Ask for confirmation
    ask_for_confirmation

    # Check the user's response
    response=$?

    if [ $response -eq 0 ]; then
        # Clear the screen and save the file
        clear
        save_list

        # Ask if the user wants to search again or quit
        ask_to_search_again

        # Check the user's response
        response=$?

        if [ $response -eq 0 ]; then
            # User wants to search again, continue the loop
            echo "Returning to the menu..."
        else
            # User wants to quit, exit the script
            clear

            # Ask if the user wants to move custom-* files to .emulationstation/collections/
            dialog --backtitle "URCade Custom Collection Creator" \
                --yesno "Move all custom-* files to $destination_folder?" 7 50

            # Check the user's response
            response=$?

            if [ $response -eq 0 ]; then
                # User wants to move the files, perform the move
                mkdir -p "$destination_folder"
                mv custom-* "$destination_folder"
                echo "Files moved to: $destination_folder"
                exit_with_message "Collections moved to ES folder. Exiting..."
            else
                # User chose not to move the files
                exit_with_message "Exiting..."
            fi
        fi
    else
        rm "$result_file"
        exit_with_message "Search results have not been saved. Returning to the menu..." "true"
        clear
    fi
done
#------------------------------ END OF FILE ----------------------------------------