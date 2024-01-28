# URCade Custom Collection Creator

The URCade Custom Collection Creator tool simplifies the process of creating custom collections for Emulation Station by scanning your ROM library with a specified search term.

## Features

- **Search and Create:** Scan your ROM library with a search term and generate a `custom-yourterm.cfg` file for use in Emulation Station's custom collections.
- **Themed Collections:** If you have themed collections, ensure that the collection name matches the theme name. The file `custom-starwars.cfg` will automatically associate with the "starwars" theme folder name.
- **Multiple Search Terms:** You can use multiple search terms in a single collection, and the tool will add to, rather than replace, the existing collection.
- **GUI or CLI:** The script supports both a graphical user interface (GUI) for interactive configuration and command-line interface (CLI) for automation.
- **Move Files Automatically:** When using the GUI, the script can move files to their correct location within Emulation Station.

## Usage

### GUI Mode

1. Run the script without any arguments:
    ```bash
    ./U.Create.Collection.sh
    ```

2. Follow the on-screen prompts to configure your search parameters.

### CLI Mode

```bash
./U.Create.Collection.sh "search term" "collection name"
```
Replace "search term" and "collection name" with your desired parameters. Spaces in search terms should be enclosed in quotes.

Note: You need to manually move CLI-generated files to the collections folder (~/.emulationstation/collections/).
