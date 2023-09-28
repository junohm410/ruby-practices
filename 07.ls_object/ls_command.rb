# frozen_string_literal: true

require 'optparse'
require_relative 'file'

class LsCommand
  NUMBER_OF_COLUMNS = 3

  def initialize
    options = ARGV.getopts('arl')

    flag = options['a'] ? File::FNM_DOTMATCH : 0
    file_names = Dir.glob('*', flag)
    file_names = file_names.reverse if options['r']
    @files = file_names.map { |file_name| File.new(file_name) }
  end

  def display_files
    width_per_file = printing_width
    files = format_files(number_of_displayed_rows)
    print_files(files, width_per_file)
  end

  private

  def printing_width
    @files.map { |file| file.name.size }.max
  end

  def number_of_displayed_rows
    number_of_files = @files.size
    number_of_files.ceildiv(NUMBER_OF_COLUMNS)
  end

  def format_files(number_of_rows)
    cols_of_files = []
    @files.each_slice(number_of_rows) do |col_of_files|
      cols_of_files << col_of_files
    end

    last_col = cols_of_files.last
    last_col << '' until last_col.size == number_of_rows

    cols_of_files.transpose
  end

  def print_files(formatted_file, width)
    formatted_file.each do |files|
      files.each do |file|
        if file == ''
          print file
        else
          print "#{file.name.ljust(width)} "
        end
      end
      print "\n"
    end
  end
end
