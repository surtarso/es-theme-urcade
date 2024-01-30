#!/bin/bash

# URCade's Emulation Station Themes Batch Operator
# Allows users to create variations of themes based on filters and effects.
# Created by Tarso Galvao Sun Jan 28 10:47:13 AM -03 2024
# Version 0.6

#--------------- THEME SETTINGS ----------------------

# Themes root folders
theme_folders=(
    "/etc/emulationstation/themes/"
    "/opt/retropie/configs/all/emulationstation/themes/"
)

# Theme image files
background_image_file="background.png"
crt_image_file="crt.png"
system_image_file="system.png"
frame_image_file="frame.png"

#------------------ CHECK DEPS -----------------------

# Requires root to alter files in /etc and /opt
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root, try with 'sudo $0'"
    exit
fi

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "Error: dialog is not installed. Please install it using 'apt install dialog'."
    exit 1
fi

# Check if imagemagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: convert is not installed. Please install it using 'apt install imagemagick'."
    exit 1
fi

#------------------ THEMES MENU ----------------------

# Create an array to store menu items
menu_items=()

# Loop through each theme folder and list subdirectories
for folder in "${theme_folders[@]}"; do
    subfolders=($(find "$folder" -maxdepth 1 -mindepth 1 -type d -exec echo "{}" \; | sort -u))
    for subfolder in "${subfolders[@]}"; do
        menu_items+=("$subfolder" "$folder")
    done
done

# Dialog menu to select a subfolder
selected_item=$(dialog --stdout --menu "Select a theme subfolder:" 0 0 0 "${menu_items[@]}")

# Check if a valid option is selected
if [ -z "$selected_item" ]; then
    clear
    echo "No theme folder found. Exiting."
    exit 1
fi

# Extract the selected subfolder and its corresponding theme folder
selected_subfolder=$(echo "$selected_item" | awk '{print $1}')
selected_theme_folder=$(echo "$selected_item" | awk '{print $2}')

echo "Selected Subfolder: $selected_subfolder"
echo "Selected Theme Folder: $selected_theme_folder"

# Change to the selected subfolder
cd "$selected_theme_folder/$selected_subfolder" || {
    echo "Error: Unable to change to the selected subfolder. Exiting."
    exit 1
}


# Check if user is in the correct directory by checking static contents
if [ ! -d _inc ] || [ ! -f theme.xml ]; then
    echo "ERROR: File 'theme.xml' and/or folder '_inc' are not found!"
    echo "It seems you are not in an Emulation Station theme folder..."
    exit 1
fi

#------------------- FILES MENU ----------------------

# Options for files
options=("$background_image_file" "Background (Consoles bg)" off
         "$crt_image_file" "CRT (Preview bg)" off
         "$system_image_file" "System (Wheel)" off
         "$frame_image_file" "Frame (Preview border)" off)

# Dialog to select files
selected_files=($(dialog --stdout --separate-output --checklist "Select files to alter:" 0 0 0 "${options[@]}"))

# Check if any files are selected
if [ ${#selected_files[@]} -eq 0 ]; then
    echo "No files selected. Exiting."
    exit 1
fi

#------------------ FUNCTIONS -----------------------

# Function to apply Black and White filter
bw() {
    echo "Applying Black and White filter in $1"
    convert "$1" -type grayscale "$1"
}

# Function to invert colors
invert_colors() {
    echo "Inverting colors in $1"
    convert "$1" -negate "$1"
}

# Function to compress with quality 80
compress_eighty() {
    echo "Compressing $1 with quality 80"
    convert "$1" -quality 80 "$1"
}

# Function to compress with quality 40
compress_forty() {
    echo "Compressing $1 with quality 40"
    convert "$1" -quality 40 "$1"
}

# Function to compress with quality 20
compress_twenty() {
    echo "Compressing $1 with quality 20"
    convert "$1" -quality 20 "$1"
}

# Function to resize images by 25%
resize_twenty_five() {
    echo "Resizing $1 to 25%"
    convert "$1" -resize 25%x25% "$1"
}

# Function to resize images by 50%
resize_fifty() {
    echo "Resizing $1 to 50%"
    convert "$1" -resize 50%x50% "$1"
}

# Function to resize images by 75%
resize_seventy_five() {
    echo "Resizing $1 to 75%"
    convert "$1" -resize 75%x75% "$1"
}

# Function to change hue
change_hue() {
    echo "Changing hue in $1"
    convert "$1" -modulate 120,150,100 "$1"
}

# Function to change saturation
change_saturation() {
    echo "Changing saturation in $1"
    convert "$1" -modulate 100,200,100 "$1"
}

# Function to apply a cartoon filter
cartoon_filter() {
    echo "Applying cartoon filter to $1"
    convert "$1" -edge 2 "$1"
}

# Function to apply a 3D shade
shader_three_d() {
    echo "Applying 3D shade filter to $1"
    convert "$1" -shade 180x45 "$1"
}

sepia_tone() {
    echo "Applying Sepia filter to $1"
    convert "$1" -sepia-tone 80% "$1"
}

dither_pattern() {
    echo "Applying Dither pattern to $1"
    convert "$1" -ordered-dither o2x2 "$1"
    # convert "$1" -ordered-dither o3x3 "$1"
    # convert "$1" -ordered-dither o4x4 "$1"
    # convert "$1" -ordered-dither o8x8 "$1"
}

# Update associative array with new functions
declare -A command_options=(
    ["bw"]="bw"
    ["invert_colors"]="invert_colors"
    ["compress_eighty"]="compress_eighty"
    ["compress_forty"]="compress_forty"
    ["compress_twenty"]="compress_twenty"
    ["resize_twenty_five"]="resize_twenty_five"
    ["resize_fifty"]="resize_fifty"
    ["resize_seventy_five"]="resize_seventy_five"
    ["change_hue"]="change_hue"
    ["change_saturation"]="change_saturation"
    ["cartoon_filter"]="cartoon_filter"
    ["shader_three_d"]="shader_three_d"
    ["sepia_tone"]="sepia_tone"
    ["dither_pattern"]="dither_pattern"
)

#--------------- COMMAND MENU ----------------------

# Subsequent dialog menu for command selection
commands=("bw" "Black and White Filter"
          "invert_colors" "Invert Colors"
          "compress_eighty" "Compress Quality 80"
          "compress_forty" "Compress Quality 40"
          "compress_twenty" "Compress Quality 20"
          "resize_twenty_five" "Resize Images by 25%"
          "resize_fifty" "Resize Images by 50%"
          "resize_seventy_five" "Resize Images by 75%"
          "change_hue" "Change Hue"
          "change_saturation" "Change Saturation"
          "cartoon_filter" "Cartoon Filter"
          "shader_three_d" "3D Shader"
          "sepia_tone" "Sepia Filter"
          "dither_pattern" "Dither Pattern")

# Subsequent dialog menu for command selection
command=$(dialog --stdout --menu "Select command to apply:" 0 0 0 "${commands[@]}")

# Check if a valid command is selected
if [ -z "${command_options[$command]}" ]; then
    echo "Invalid command. Exiting."
    exit 1
fi

#--------------- FOLDER CREATION --------------------

# Create a new theme folder based on the selected command
new_folder="../es-theme-custom-$command"
mkdir -p "$new_folder"

# Copy current theme to the new folder
cp -var ./* "$new_folder"

# Enter new theme folder
cd "$new_folder"

#---------------- MAIN LOOP -------------------------

# Loop to alter selected files based on the chosen command in the new folder
for d in *; do
    # Enter system folder
    if [ -d "$d" ] && [ "$d" != "_inc" ]; then
        # Enter images folder
        cd "$d/_inc" || exit
        echo -e "\nEntering $d folder"
        for file in "${selected_files[@]}"; do
            # Alter the image if it exists
            if [ -f "$file" ]; then
                ${command_options[$command]} "$file"
            else
                echo "WARNING: $file not found in $d"
            fi
        done
        # Return to the parent folder
        echo "done."
        cd - >/dev/null 2>&1
    fi
done

# Display success message with the path to the modified files
echo -e "Files altered successfully. Modified files are in: $PWD"

#--------------- END OF FILE -----------------------