#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

NUMBER_OF_COLUMNS = 3

def number_of_displayed_rows(files)
  number_of_files = files.size
  number_of_files.ceildiv(NUMBER_OF_COLUMNS)
end

def format_files(files, number_of_rows)
  cols_of_files = []
  files.each_slice(number_of_rows) do |col_of_files|
    cols_of_files << col_of_files
  end

  last_col = cols_of_files.last
  last_col << '' until last_col.size == number_of_rows

  cols_of_files.transpose
end

def print_files(formatted_file, width)
  formatted_file.each do |files|
    files.each { |file| print "#{file.ljust(width)} " }
    print "\n"
  end
end

def display_files
  flag = ARGV.getopts('a')['a'] ? File::FNM_DOTMATCH : 0
  files = Dir.glob('*', flag)
  width_per_file = files.map(&:size).max

  files = format_files(files, number_of_displayed_rows(files))

  print_files(files, width_per_file)
end

display_files
