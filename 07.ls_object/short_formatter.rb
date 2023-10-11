# frozen_string_literal: true

class ShortFormatter
  DISPLAYED_COLUMNS_COUNT = 3

  def initialize(file_names)
    @file_names = file_names
  end

  def format_files
    longest_file_name_string_length = find_longest_string_length(@file_names)
    displayed_rows_count = count_displayed_rows

    file_names_cols =
      @file_names.each_slice(displayed_rows_count).map do |file_names_col|
        file_names_col.map { |file_name| file_name.ljust(longest_file_name_string_length) }
      end

    last_col = file_names_cols.last
    last_col << '' until last_col.size == displayed_rows_count

    file_names_cols.transpose.map { |files_row| files_row.join(' ') }
  end

  private

  def find_longest_string_length(file_prop_strings)
    file_prop_strings.map(&:size).max
  end

  def count_displayed_rows
    files_count = @file_names.size
    files_count.ceildiv(DISPLAYED_COLUMNS_COUNT)
  end
end
