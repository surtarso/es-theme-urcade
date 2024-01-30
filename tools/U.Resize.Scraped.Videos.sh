#!/bin/bash

# Batch Operator to resize scrapped videos
# Tarso Galvao Tue Jan 30 03:04:16 PM -03 2024
# Version 1.0

# Function to display resolution presets
display_presets() {
    echo "Select target resolution (or type 'C' for custom):"
    echo "1. 1080p"
    echo "2. 720p"
    echo "3. 480p"
    echo "4. 240p"
    echo "5. 120p"
}

# Get videos location (cannot be empty, and must exist)
while true; do
    read -p "Enter the location of the videos (ex.: '~/Retropie/roms/[system]/media/videos/'): " VIDEOS_LOCATION
    if [ -z "$VIDEOS_LOCATION" ]; then
        echo "Please provide a valid location."
    elif [ ! -d "$VIDEOS_LOCATION" ]; then
        echo "The provided directory does not exist. Please provide a valid location."
    else
        break
    fi
done

# Get target resolution
display_presets
read -p "Enter the number corresponding to the desired resolution (or type 'C' for custom): " RESOLUTION_CHOICE

# Case statement to handle resolution choices
case $RESOLUTION_CHOICE in
    1) RES="1920x1080";;
    2) RES="1280x720";;
    3) RES="854x480";;
    4) RES="426x240";;
    5) RES="208x120";;
    [Cc]) 
        # Custom resolution input
        while true; do
            read -p "Enter the custom resolution (e.g., '640x480'): " CUSTOM_RESOLUTION
            # Validate custom resolution format (digitsxdigits)
            if [[ $CUSTOM_RESOLUTION =~ ^[0-9]+x[0-9]+$ ]]; then
                RES="$CUSTOM_RESOLUTION"
                break
            else
                echo "Invalid custom resolution format. Please enter a valid resolution (e.g., '640x480')."
            fi
        done
        ;;
    *) echo "Invalid choice. Using default 480p resolution (854x480)."; RES="854x480";;
esac

# Ask whether to keep original files (loop until valid answer)
while true; do
    read -p "Do you want to keep the original files? (y/n): " KEEP

    # Validate user choice for keeping original files
    if [[ $KEEP == "y" || $KEEP == "n" ]]; then
        # Echo a message based on user's choice
        if [ $KEEP == "y" ]; then
            echo "Original files will be moved to $VIDEOS_LOCATION original/"
        else
            echo "We will overwrite existing files!"
            read -p "Are you sure you want to proceed? (y/n): " OVERWRITE_CONFIRM
            if [ $OVERWRITE_CONFIRM != "y" ]; then
                echo "Aborted."
                exit 1
            fi
        fi
        break  # Exit the loop if a valid choice is provided
    else
        echo "Invalid choice. Please enter 'y' for Yes or 'n' for No."
    fi
done

echo "We will process videos in $VIDEOS_LOCATION for $RES. Keep originals: $KEEP"
echo "Starting in 3 seconds, press CRTL + C to abort..."
sleep 3

# execute the batch operation
echo "Executing batch operation..."

for d in "$VIDEOS_LOCATION"; do
    if [ -d "$d" ]; then
        echo "Processing directory: $d)"
        cd "$d" || exit

        # Loop through video files
        for f in $FILE; do
            echo "Processing file: $f"
            # Resize videos and maintain aspect ratio
            ffmpeg -i "$f" -vf "scale=$RES:force_original_aspect_ratio=decrease" -acodec copy -y "${f}-new.mp4"

            # Move processed files or create 'original' folder
            if [ $KEEP == "n" ]; then
                mv "${f}-new.mp4" "$f"
            else
                # Create 'original' folder if it doesn't exist
                [ -d original ] || mkdir original
                # Move original files to 'original' folder
                mv "$f" original/
            fi
        done

        cd - >/dev/null 2>&1 || exit
    fi
done

echo "Batch operation completed."
exit 0
