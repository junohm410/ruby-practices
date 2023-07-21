#!/usr/bin/env ruby
# frozen_string_literal: true

def get_number_of_displayed_rows(files)
  number_of_files = files.size
  quatient_and_remainder = number_of_files.divmod(3)

  if quatient_and_remainder[1].zero?
    quatient_and_remainder[0]
  else
    quatient_and_remainder[0] + 1
  end
end

def get_array_of_files_used_for_printing(files, number_of_rows)
  array_of_files = []
  files.each_slice(number_of_rows) do |col_of_files|
    array_of_files << col_of_files
  end

  last_col = array_of_files.last
  last_col << '' until last_col.size == number_of_rows

  array_of_files.transpose
end

def print_files(array_of_files, number_of_characters)
  array_of_files.each do |array|
    array.each.with_index(1) do |file, i|
      if i == array.size
        print file
      else
        print "#{file.ljust(number_of_characters)} "
      end
    end
    print "\n"
  end
end

def display_files
  files_of_current_directory = Dir.glob('*')
  number_of_characters_in_the_longest_filename = files_of_current_directory.map(&:size).max

  number_of_displayed_rows = get_number_of_displayed_rows(files_of_current_directory)
  array_of_files_for_printing = get_array_of_files_used_for_printing(files_of_current_directory, number_of_displayed_rows)

  print_files(array_of_files_for_printing, number_of_characters_in_the_longest_filename)
end

display_files
