# URCade Custom Collection Creator

The URCade Custom Collection Creator tool simplifies the process of creating custom collections for Emulation Station by scanning your ROM library with a specified search term.

## Features

- **Search and Create:** Scan your ROM library with a search term and generate a `custom-yourterm.cfg` file for use in Emulation Station's custom collections.
- **Themed Collections:** If you have themed collections, ensure that the collection name matches the theme name. The file `custom-starwars.cfg` will automatically associate with the "starwars" theme folder name.
- **Multiple Search Terms:** You can use multiple search terms in a single collection, and the tool will add to, rather than replace, the existing collection.
- **GUI or CLI:** The script supports both a graphical user interface (GUI) for interactive configuration and command-line interface (CLI) for automation.
- **Move Files Automatically:** When using the GUI, the script can move files to their correct location within Emulation Station. You need to restart ES for lists to show.

## Usage

### General
- The **search term** wont care about caps. "Mario" or "mario" will get same hits. Remeber to quote terms with spaces in CLI mode.
- The **collection name** has two format options: Themed and Unthemed (list). 
  - **Themed** collections folder name and collection name must match. If your theme has a folder for Sonic collection called 'sonic_col', the collection name MUST be 'sonic_col'.
  - **Unthemed** collection will be shown as a list, so you can name it as you want. Ex.: "Sonic, the hedgehog - Collection". Just remember to use quotes in names with spaces in CLI mode
- The **output collection file** will be properly formated as **custom-your_collection_name.cfg** on the same location the script was executed (Unless requested to be moved to the default collection folder (GUI only))

### Notes
- **For obvious reasons, this script will not work for arcade games using mame naming convention.**
- The script will ignore the 'media' folder so it wont erroneously put media files into the rom list. If you named you media folders diferently you can either edit the script of move/rename them while creating lists.
- Be sure to check the created list for extension mismatch, since it will add 'mario.nes' and 'mario.srm' (save game file) in some configurations. Just open the .cfg with any text editor and remove lines you dont want or remove them within Emulation Station UI.

### CLI Mode
Replace "search term" and "collection name" with your desired parameters. Spaces in args should be enclosed in quotes.
```bash
./U.Create.Collection.sh "search term" "collection name"
```
Note: You need to manually move CLI-generated files to the collections folder (~/.emulationstation/collections/).

### GUI Mode
Run the script without any arguments and follow the on-screen prompts to configure your search parameters.
```bash
./U.Create.Collection.sh
```

 

