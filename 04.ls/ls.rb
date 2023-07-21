#!/usr/bin/env ruby
# frozen_string_literal: true

def number_of_displayed_rows(files)
  number_of_files = files.size
  quotient, remainder = number_of_files.divmod(3)

  quotient += 1 unless remainder.zero?
  quotient
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
  files = Dir.glob('*')
  width_per_file = files.map(&:size).max

  lines_per_print = number_of_displayed_rows(files)
  files_for_print = format_files(files, lines_per_print)

  print_files(files_for_print, width_per_file)
end

display_files
