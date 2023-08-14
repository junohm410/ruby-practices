#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

PRINTING_WIDTH = 8

def main
  options = ARGV.getopts('lwc')
  ARGV.none? ? print_pipelined_input(options) : print_specified_files(ARGV, options)
end

def print_pipelined_input(options)
  input_data_lines = $stdin.readlines

  line_count = count_lines(input_data_lines)
  word_count = count_words(input_data_lines)
  file_size = count_bytesize(input_data_lines)

  input_data_properties = [{ line_count:, word_count:, file_size:, file_name: '' }]

  print_files_own_properties(input_data_properties, options)
end

def print_specified_files(files, options)
  files_info = format_files_own_properties(files)

  print_files_own_properties(files_info, options)
end

def format_files_own_properties(files)

  formatted_files_own_properties_sets =
    files.map do |file|
      file_lines = File.open(file, &:readlines)
      line_count = count_lines(file_lines)
      word_count = count_words(file_lines)
      file_size = count_bytesize(file_lines)
      file_name = file
      { line_count:, word_count:, file_size:, file_name: }
    end
  
  if files.size > 1
    line_count = 0
    word_count = 0
    file_size = 0
    file_name = 'total'
    formatted_files_own_properties_sets.each do |file|
      line_count += file[:line_count]
      word_count += file[:word_count]
      file_size += file[:file_size]
    end
    formatted_files_own_properties_sets << { line_count:, word_count:, file_size:, file_name: }
  end

  formatted_files_own_properties_sets
end

def count_lines(lines)
  lines_num = lines.size
  lines.none? || lines.last.end_with?("\n") ? lines_num : lines_num - 1
end

def count_words(lines)
  lines.sum { |line| line.split.size }
end

def count_bytesize(lines)
  lines.join.bytesize
end

def print_files_own_properties(files_properties, options)
  files_properties.each do |file_properties|
    output = arrange_output_line(file_properties, options)
    puts output + " #{file_properties[:file_name]}"
  end
end

def arrange_output_line(properties, options)
  is_option_none = options.values.none?
  output = ''
  output += properties[:line_count].to_s.rjust(PRINTING_WIDTH) if options['l'] || is_option_none
  output += properties[:word_count].to_s.rjust(PRINTING_WIDTH) if options['w'] || is_option_none
  output += properties[:file_size].to_s.rjust(PRINTING_WIDTH) if options['c'] || is_option_none
  output
end

main
