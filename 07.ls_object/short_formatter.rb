# frozen_string_literal: true

class ShortFormatter
  DISPLAYED_COLUMNS_COUNT = 3

  def initialize(files)
    @files = files
  end

  def format_files
    file_names = @files.map(&:name)
    longest_file_name_string_length = find_longest_string_length(file_names)
    displayed_rows_count = count_displayed_rows

    files_cols =
      @files.each_slice(displayed_rows_count).map do |files_col|
        files_col.map { |file| file.name.ljust(longest_file_name_string_length) }
      end

    last_col = files_cols.last
    last_col << '' until last_col.size == displayed_rows_count

    files_cols.transpose.map { |files_row| files_row.join(' ') }
  end

  private

  def find_longest_string_length(file_prop_strings)
    file_prop_strings.map(&:size).max
  end

  def count_displayed_rows
    files_count = @files.size
    files_count.ceildiv(DISPLAYED_COLUMNS_COUNT)
  end
end
