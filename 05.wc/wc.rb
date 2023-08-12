#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

DEFAULT_WIDTH = 8

def main
  options = ARGV.getopts('lwc')
  ARGV.none? ? print_from_stdin(options) : print_from_args(ARGV, options)
end

def print_from_stdin(options)
  input_data_lines = $stdin.readlines

  lines_num = lines_num(input_data_lines)
  words_num = input_data_lines.sum { |line| line.split.size }
  file_size = input_data_lines.join.bytesize
  total_nums = { 'total_lines' => lines_num, 'total_words' => words_num, 'total_size' => file_size }

  print_total(total_nums, options)
  print "\n"
end

def print_from_args(files, options)
  files_info = format_files_info(files)

  if files.size > 1
    print_info(files_info[:lines_words_sizes], files_info[:total_nums], options)
    print_total(files_info[:total_nums], options)
    print " total\n"
  else
    print_info(files_info[:lines_words_sizes], files_info[:total_nums], options)
  end
end

def format_files_info(files)
  all_files_lines = files.map { |file| File.open(file, &:readlines) }

  lines_nums = calc_lines_nums(all_files_lines)
  total_lines_nums = lines_nums.sum

  words_nums = calc_words_nums(all_files_lines)
  total_words_nums = words_nums.sum

  file_sizes = calc_sizes(all_files_lines)
  total_size = file_sizes.sum

  lines_words_sizes = [lines_nums, words_nums, file_sizes, files].transpose
  keys = %w[lines_num words_num file_size file_name]
  formatted_3_elemetnts_info =
    lines_words_sizes.map { |info| [keys, info].transpose.to_h }

  total_nums = [total_lines_nums, total_words_nums, total_size]
  keys = %w[total_lines total_words total_size]
  formatted_total_nums = [keys, total_nums].transpose.to_h

  {
    lines_words_sizes: formatted_3_elemetnts_info,
    total_nums: formatted_total_nums
  }
end

def calc_lines_nums(files_lines)
  files_lines.map { |file_lines| lines_num(file_lines) }
end

def calc_words_nums(files_lines)
  files_lines.map do |file_lines|
    file_lines.sum { |line| line.split.size }
  end
end

def calc_sizes(files_lines)
  files_lines.map { |file_lines| file_lines.join.bytesize }
end

def lines_num(lines)
  lines_num = lines.size
  lines_num -= 1 unless lines.last.end_with?("\n")
  lines_num = 0 if lines.none?
  lines_num
end

def calc_width(nums)
  width = nums.values.map { |num| num.to_s.size }.max
  width + 1 > DEFAULT_WIDTH ? width + 1 : DEFAULT_WIDTH
end

def print_info(files, total_nums, options)
  width = calc_width(total_nums)
  output = ''
  is_option_none = options.values.none?
  files.each do |file|
    output += file['lines_num'].to_s.rjust(width) if options['l'] || is_option_none
    output += file['words_num'].to_s.rjust(width) if options['w'] || is_option_none
    output += file['file_size'].to_s.rjust(width) if options['c'] || is_option_none
    output += " #{file['file_name']}\n"
  end
  print output
end

def print_total(total_nums, options)
  width = calc_width(total_nums)
  output = ''
  is_option_none = options.values.none?
  output += total_nums['total_lines'].to_s.rjust(width) if options['l'] || is_option_none
  output += total_nums['total_words'].to_s.rjust(width) if options['w'] || is_option_none
  output += total_nums['total_size'].to_s.rjust(width) if options['c'] || is_option_none
  print output
end

main
