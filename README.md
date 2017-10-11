# ruby-read-write-sheet
Ruby sample application that loads a sheet, updates selected cells, and saves the results

This is a minimal Smartsheet sample that demonstrates how to
* Load a sheet
* Loop through the rows
* Check for rows that meet a criteria
* Update cell values
* Write the results back to the original sheet


This sample scans a sheet for rows where the value of the "Status" column is "Complete" and sets the "Remaining" column to zero.
This is implemented in the `build_update_complete_row` method which you should modify to meet your needs.


## Setup
* Install the smartsheet library with `gem install smartsheet --pre` or `bundle` at the command line
* Import the sample data from "Sample Sheet.xlsx" into a new sheet

* Update the `config.json` file with these two settings:
    * An API access token, obtained from the Smartsheet Account button, under Personal settings
    * The Sheet Id, obtained from sheet properties 

* Run the application using your preferred IDE or at the command line with `ruby read_write_sheet.rb` 

The rows marked "Complete" will have the "Remaining" value set to 0. (Note that you will have to refresh in the desktop application to see the changes)

## See also
- http://smartsheet-platform.github.io/api-docs/
- https://github.com/smartsheet-platform/smartsheet-ruby-sdk
- https://www.smartsheet.com/