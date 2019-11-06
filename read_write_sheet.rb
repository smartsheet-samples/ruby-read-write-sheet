require 'smartsheet'
require 'logger'

# Find cell in a row, based on column name
def get_cell_by_column_name(row, column_name, column_map)
  column_id = column_map[column_name]
  row[:cells].find {|cell| cell[:column_id] == column_id}
end

# Evaluate row contents, and build update info if needed
def evaluate_row_and_build_update(row, column_map)
  status_cell = get_cell_by_column_name(row, 'Status', column_map)
  remaining_cell = get_cell_by_column_name(row, 'Remaining', column_map)

  row_to_update = nil

  # Check if status is complete but remaining is not 0
  if status_cell[:display_value] == 'Complete' && remaining_cell[:display_value] != '0'
    puts "Updating row #{row[:row_number]}"
    row_to_update = {
      id: row[:id],
      cells: [{
        columnId: remaining_cell[:column_id],
        value: 0
      }]
    }
  end
  return row_to_update
end

# Import an Excel sheet to operate on; see the bundled 'Sample Sheet.xlsx'
def import_excel_sheet(client, file_path, sheet_name)
  result = client.sheets.import_from_file_path(
    path: file_path,
    file_type: :xlsx,
    params: {
      sheetName: sheet_name,
      headerRowIndex: 0,
      primaryColumnIndex: 0
    }
  )[:result]

  puts "Imported Excel doc to sheet named '#{result[:name]}'"

  result[:id]
end

# TODO: Edit config.json to set desired sheet id and API token
config = JSON.load(File.open('config.json'))

# Sample sheet file to import to Smartsheet
excel_file_path = config['source_excel_path']

# Name to assign to the imported sheet
sheet_name = config['sheet_name']

# Configure logging
logger = Logger.new(STDOUT)
logger.level = Logger::INFO

# Initialize client SDK. Uses the access token stored in environment variable "SMARTSHEET_ACCESS_TOKEN"
client = Smartsheet::Client.new(logger: logger)

begin
  # Import sample sheet
  sheet_id = import_excel_sheet(client, excel_file_path, sheet_name)

  # Load entire sheet
  sheet = client.sheets.get(sheet_id: sheet_id)
  puts "Loaded #{sheet[:total_row_count]} rows from sheet '#{sheet[:name]}'"

  # Build column map for later reference - converts column name to column id
  column_map = {}
  sheet[:columns].each do |column|
    column_map[column[:title]] = column[:id]
  end

  # Accumulate rows needing update here
  rows_to_update = []

  # Evaluate each row
  sheet[:rows].each do |row|
    update_row = evaluate_row_and_build_update(row, column_map)
    rows_to_update.push(update_row) unless update_row.nil?
  end

  if rows_to_update.empty?
    puts 'No Update Required'
  else
    # Save changes to sheet
    client.sheets.rows.update(sheet_id: sheet[:id], body: rows_to_update)
  end

rescue Smartsheet::ApiError => e
  puts 'API returned error:'
  puts "\t error code: #{e.error_code}"
  puts "\t message: #{e.message}"
  puts "\t ref id: #{e.ref_id}"
end
