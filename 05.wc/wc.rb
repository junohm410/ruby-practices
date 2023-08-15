#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

PRINTING_WIDTH = 8

def main
  options = ARGV.getopts('lwc')
  ARGV.none? ? print_pipelined_input(options) : print_specified_files(ARGV, options)
end

def print_pipelined_input(options)
  stdin_lines = $stdin.readlines

  stdin_prop = format_file_prop(stdin_lines)
  stdin_prop[:file_name] = ''

  print_file_props([stdin_prop], options)
end

def print_specified_files(files, options)
  total_file_prop_count = { line_count: 0, word_count: 0, bytesize: 0, file_name: 'total' }

  file_props =
    files.map do |file|
      file_lines = File.open(file, &:readlines)
      file_prop = format_file_prop(file_lines, total_file_prop_count)
      file_prop[:file_name] = file
      file_prop
    end

  file_props << total_file_prop_count if files.size > 1

  print_file_props(file_props, options)
end

def format_file_prop(file_lines, total_file_prop_count = nil)
  line_count = count_lines(file_lines)
  word_count = count_words(file_lines)
  bytesize = count_bytesize(file_lines)

  unless total_file_prop_count.nil?
    total_file_prop_count[:line_count] += line_count
    total_file_prop_count[:word_count] += word_count
    total_file_prop_count[:bytesize] += bytesize
  end

  { line_count:, word_count:, bytesize: }
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
