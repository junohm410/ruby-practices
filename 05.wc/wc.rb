#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

DEFAULT_WIDTH = 8

def main
  options = ARGV.getopts('lwc')
  ARGV.none? ? print_from_stdin(options) : print_from_args(ARGV, options)
end

def print_from_stdin(options)
  input_data = $stdin.read
  lines = input_data.split("\n")

  lines_num = lines.size
  words_num = lines.map { |line| line.split.size }.sum
  file_size = input_data.bytesize
  total_nums = [lines_num, words_num, file_size]

  width = calc_width(total_nums)

  print_total(total_nums, width, options)
  print "\n"
end

def print_from_args(files, options)
  lines_nums = calc_lines_nums(files)
  total_lines_nums = lines_nums.sum

  words_nums = calc_words_nums(files)
  total_words_nums = words_nums.sum

  file_sizes = calc_sizes(files)
  total_size = file_sizes.sum

  total_nums = [total_lines_nums, total_words_nums, total_size]
  width = calc_width(total_nums)

  files_info = [lines_nums, words_nums, file_sizes, files]
  formatted_info = files_info.transpose

  if files.size > 1
    print_info(formatted_info, width, options)
    print_total(total_nums, width, options)
    print " total\n"
  else
    print_info(formatted_info, width, options)
  end
end

def calc_lines_nums(files)
  files.map do |file|
    lines = File.open(file, &:readlines)
    lines_num(lines)
  end
end

def calc_words_nums(files)
  files.map do |file|
    lines = File.open(file, &:readlines)
    lines.sum { |line| line.split.size }
  end
end

def calc_sizes(files)
  files.map do |file|
    file_stat = File.stat(file)
    file_stat.size
  end
end

def lines_num(lines)
  lines_num = lines.size
  lines_num -= 1 unless lines.last.end_with?("\n")
  lines_num = 0 if lines.none?
  lines_num
end

def calc_width(nums)
  width = nums.map { |num| num.to_s.size }.max
  width + 1 > DEFAULT_WIDTH ? width + 1 : DEFAULT_WIDTH
end

def print_info(files, width, options)
  output = ''
  is_option_none = options.values.none?
  files.each do |file|
    output += file[0].to_s.rjust(width) if options['l'] || is_option_none
    output += file[1].to_s.rjust(width) if options['w'] || is_option_none
    output += file[2].to_s.rjust(width) if options['c'] || is_option_none
    output += " #{file[3]}\n"
  end
  print output
end

def print_total(total_nums, width, options)
  output = ''
  is_option_none = options.values.none?
  output += total_nums[0].to_s.rjust(width) if options['l'] || is_option_none
  output += total_nums[1].to_s.rjust(width) if options['w'] || is_option_none
  output += total_nums[2].to_s.rjust(width) if options['c'] || is_option_none
  print output
end

main
