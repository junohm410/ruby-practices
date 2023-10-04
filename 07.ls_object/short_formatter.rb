# frozen_string_literal: true

require_relative 'ls_command'
require_relative 'file'
require_relative 'formatter'

class ShortFormatter < Formatter
  def format_files
    file_names = @files.map(&:name)
    file_name_width = Formatter.find_longest_string_length(file_names)
    displayed_rows_count = count_displayed_rows

    files_cols =
      @files.each_slice(displayed_rows_count).map do |files_col|
        files_col.map { |file| file.name.ljust(file_name_width) }
      end

    last_col = files_cols.last
    last_col << '' until last_col.size == displayed_rows_count

    files_cols.transpose.map { |files_row| files_row.join(' ') }
  end

  private

  def count_displayed_rows
    files_count = @files.size
    files_count.ceildiv(LsCommand::NUMBER_OF_COLUMNS)
  end
end
