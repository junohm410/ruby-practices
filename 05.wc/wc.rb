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

  stdin_props = count_file_props(stdin_lines)
  stdin_props[:file_name] = ''

  print_file_props_list([stdin_props], options)
end

def print_specified_files(files, options)
  total = { line_count: 0, word_count: 0, bytesize: 0, file_name: 'total' }

  file_props_list =
    files.map do |file|
      file_lines = File.open(file, &:readlines)
      file_props = count_file_props(file_lines)
      total[:line_count] += file_props[:line_count]
      total[:word_count] += file_props[:word_count]
      total[:bytesize] += file_props[:bytesize]
      file_props[:file_name] = file
      file_props
    end

  file_props_list << total if files.size > 1

  print_file_props_list(file_props_list, options)
end

def count_file_props(file_lines)
  line_count = count_lines(file_lines)
  word_count = count_words(file_lines)
  bytesize = count_bytesize(file_lines)
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

def print_file_props_list(file_props_list, options)
  file_props_list.each do |file_props|
    line = arrange_line(file_props, options)
    puts line + " #{file_props[:file_name]}"
  end
end

def arrange_line(file_props, options)
  is_option_none = options.values.none?
  line = ''
  line += file_props[:line_count].to_s.rjust(PRINTING_WIDTH) if options['l'] || is_option_none
  line += file_props[:word_count].to_s.rjust(PRINTING_WIDTH) if options['w'] || is_option_none
  line += file_props[:bytesize].to_s.rjust(PRINTING_WIDTH) if options['c'] || is_option_none
  line
end

main
