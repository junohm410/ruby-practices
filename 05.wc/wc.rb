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
  bytesize = count_bytesize(input_data_lines)

  input_data_props = [{ line_count:, word_count:, bytesize:, file_name: '' }]

  print_file_props(input_data_props, options)
end

def print_specified_files(files, options)
  file_props =
    files.map do |file|
      file_lines = File.open(file, &:readlines)
      line_count = count_lines(file_lines)
      word_count = count_words(file_lines)
      bytesize = count_bytesize(file_lines)
      { line_count:, word_count:, bytesize:, file_name: file }
    end

  if files.size > 1
    line_count = 0
    word_count = 0
    bytesize = 0
    file_props.each do |file_prop|
      line_count += file_prop[:line_count]
      word_count += file_prop[:word_count]
      bytesize += file_prop[:bytesize]
    end
    file_props << { line_count:, word_count:, bytesize:, file_name: 'total' }
  end

  print_file_props(file_props, options)
end

def count_lines(lines)
  line_count = lines.size
  lines.none? || lines.last.end_with?("\n") ? line_count : line_count - 1
end

def count_words(lines)
  lines.sum { |line| line.split.size }
end

def count_bytesize(lines)
  lines.join.bytesize
end

def print_file_props(file_props, options)
  file_props.each do |file_prop|
    arranged_output_line = arrange_output_line(file_prop, options)
    puts arranged_output_line + " #{file_prop[:file_name]}"
  end
end

def arrange_output_line(file_prop, options)
  is_option_none = options.values.none?
  output_line = ''
  output_line += file_prop[:line_count].to_s.rjust(PRINTING_WIDTH) if options['l'] || is_option_none
  output_line += file_prop[:word_count].to_s.rjust(PRINTING_WIDTH) if options['w'] || is_option_none
  output_line += file_prop[:bytesize].to_s.rjust(PRINTING_WIDTH) if options['c'] || is_option_none
  output_line
end

main
