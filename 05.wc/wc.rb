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

  input_data_properties = [{ 'line_count' => line_count, 'word_count' => word_count, 'file_size' => file_size, 'file_name' => '' }]

  print_files_own_properties(input_data_properties, options)
end

def print_specified_files(files, options)
  files_info = format_files_own_properties(files)

  print_files_own_properties(files_info[:unique_properties], options)
  print_total_counts(files_info[:total_counts], options) if files.size > 1
end

def format_files_own_properties(files)
  all_files_lines = files.map { |file| File.open(file, &:readlines) }

  line_counts = all_files_lines.map { |file_lines| count_lines(file_lines) }
  total_line_count = line_counts.sum

  word_counts = all_files_lines.map { |file_lines| count_words(file_lines) }
  total_word_count = word_counts.sum

  file_sizes = all_files_lines.map { |file_lines| count_bytesize(file_lines) }
  total_size = file_sizes.sum

  files_own_properties_sets = [line_counts, word_counts, file_sizes, files].transpose
  formatted_files_own_properties_sets =
    files_own_properties_sets.map do |file_properties|
      { 'line_count' => file_properties[0], 'word_count' => file_properties[1], 'file_size' => file_properties[2], 'file_name' => file_properties[3] }
    end

  total_counts = [total_line_count, total_word_count, total_size]
  total_counts_keys = %w[line_count word_count file_size]
  formatted_total_counts = [total_counts_keys, total_counts].transpose.to_h

  {
    unique_properties: formatted_files_own_properties_sets,
    total_counts: formatted_total_counts
  }
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
    puts output + " #{file_properties['file_name']}"
  end
end

def print_total_counts(total_counts, options)
  output = arrange_output_line(total_counts, options)
  puts "#{output} total"
end

def arrange_output_line(properties, options)
  is_option_none = options.values.none?
  output = ''
  output += properties['line_count'].to_s.rjust(PRINTING_WIDTH) if options['l'] || is_option_none
  output += properties['word_count'].to_s.rjust(PRINTING_WIDTH) if options['w'] || is_option_none
  output += properties['file_size'].to_s.rjust(PRINTING_WIDTH) if options['c'] || is_option_none
  output
end

main
