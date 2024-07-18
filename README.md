# rf2_league_pkg_builder

## Disclaimer

All scripts are provided "as is" - no warranty for correct functionality.

## Note

If using automatic Steam workshop upload ... passwords (see end of rf2_league_pkg_builder.ps1) with some special characters will cause problems handling them in variables.

## General

...

## Usage

### Preparation

1. Change $RF2ROOT in variables.ps1 if rFactor 2 is not installed to default path

2. change to helper and run prepare.ps1

3. go back and copy skin files to vehicle folders

4. copy or create veh, ini and all that other stuff of a skin package in vehicle folders

### Running on CLI

1. run rf2_league_pkg_builder.ps1 

2. upload the rfcmps from content folder to steam workshop (if not enabled at end of script)

or

2. copy the rfcmps to $RF2ROOT\Packages and run content management in rF2 to install them

### Running HTML-UI

1. go to html-ui

2. run install_html_ui.ps1

3. start nginx and php by running start_nginx.bat

4. open browser and run http://localhost:9122


