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

  lines_num = count_lines(input_data_lines)
  words_num = count_words(input_data_lines)
  file_size = count_bytesize(input_data_lines)

  lines_words_sizes = [{ 'lines_num' => lines_num, 'words_num' => words_num, 'file_size' => file_size, 'file_name' => '' }]
  width = [lines_num, words_num, file_size].max.to_s.size
  width = width + 1 > DEFAULT_WIDTH ? width + 1 : DEFAULT_WIDTH

  print_info(lines_words_sizes, width, options)
end

def print_from_args(files, options)
  files_info = format_files_info(files)

  width = calc_width(files_info[:total_nums])
  print_info(files_info[:lines_words_sizes], width, options)
  print_total(files_info[:total_nums], width, options) if files.size > 1
end

def format_files_info(files)
  all_files_lines = files.map { |file| File.open(file, &:readlines) }

  lines_nums = all_files_lines.map { |file_lines| count_lines(file_lines) }
  total_lines_nums = lines_nums.sum

  words_nums = all_files_lines.map { |file_lines| count_words(file_lines) }
  total_words_nums = words_nums.sum

  file_sizes = all_files_lines.map { |file_lines| count_bytesize(file_lines) }
  total_size = file_sizes.sum

  lines_words_sizes = [lines_nums, words_nums, file_sizes, files].transpose
  lines_words_sizes_keys = %w[lines_num words_num file_size file_name]
  formatted_3_elements_info =
    lines_words_sizes.map { |file_info| [lines_words_sizes_keys, file_info].transpose.to_h }

  total_nums = [total_lines_nums, total_words_nums, total_size]
  total_nums_keys = %w[lines_num words_num file_size]
  formatted_total_nums = [total_nums_keys, total_nums].transpose.to_h

  {
    lines_words_sizes: formatted_3_elements_info,
    total_nums: formatted_total_nums
  }
end

def count_lines(lines)
  lines_num = lines.size
  lines_num -= 1 unless lines.none? || lines.last.end_with?("\n")
  lines_num
end

def count_words(lines)
  lines.sum { |line| line.split.size }
end

def count_bytesize(lines)
  lines.join.bytesize
end

def calc_width(nums)
  width = nums.values.map { |num| num.to_s.size }.max
  width + 1 > DEFAULT_WIDTH ? width + 1 : DEFAULT_WIDTH
end

def print_info(files_data, width, options)
  output = ''
  is_option_none = options.values.none?
  files_data.each do |file_data|
    output = arrange_each_file(output, file_data, width, options, is_option_none)
    output += " #{file_data['file_name']}\n"
  end
  print output
end

def print_total(total_nums, width, options)
  output = ''
  is_option_none = options.values.none?
  output = arrange_each_file(output, total_nums, width, options, is_option_none)
  output += " total\n"
  print output
end

def arrange_each_file(output, file_data, width, options, is_option_none)
  output += file_data['lines_num'].to_s.rjust(width) if options['l'] || is_option_none
  output += file_data['words_num'].to_s.rjust(width) if options['w'] || is_option_none
  output += file_data['file_size'].to_s.rjust(width) if options['c'] || is_option_none
  output
end

main
