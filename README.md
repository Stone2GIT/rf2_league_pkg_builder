# rFactor 2 League Package Builder

## Disclaimer

All scripts are provided "as is" - no warranty for correct functionality.

## Note

If using automatic Steam workshop upload ... passwords (see end of rf2_league_pkg_builder.ps1) with some special characters will cause problems handling them in variables.

## Quick start guide

### Preparation

1. Clone the repo ...

2. Change $RF2ROOT in variables.ps1 if rFactor 2 is not installed to default path

3. change to helper and run prepare.ps1

4. go back and copy skin files to vehicle folders

5. copy or create veh, ini and all that other stuff of a skin package in vehicle folders

### Running on CLI

1. run rf2_league_pkg_builder.ps1 

2. copy existing metadata.vdf from previous upload to rf2_league_pkg_builder folder

3. upload the rfcmps from content folder to steam workshop (if variables are not set in variables.ps1)

or

3. copy the rfcmps to $RF2ROOT\Packages and run content management in rF2 to install them

### Running HTML-UI

1. go to html-ui

2. run install_html_ui.ps1

3. copy existing metadata.vdf from previous upload to rf2_league_pkg_builder folder

4. start nginx and php by running start_nginx.bat

5. open browser and run http://localhost:9122
