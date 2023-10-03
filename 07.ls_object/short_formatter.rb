# frozen_string_literal: true

require_relative 'ls_command'
require_relative 'file'
require_relative 'formatter'

class ShortFormatter < Formatter
  def format_files
    files_cols = []
    rows_count = count_displayed_rows
    @files.each_slice(rows_count) do |files_col|
      files_cols << files_col
    end

    last_col = files_cols.last
    last_col << '' until last_col.size == rows_count

    files_cols.transpose
  end

  private

  def count_displayed_rows
    files_count = @files.size
    files_count.ceildiv(LsCommand::NUMBER_OF_COLUMNS)
  end
end
