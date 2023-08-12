#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

DEFAULT_WIDTH = 8
OPTIONS = ARGV.getopts('lwc')

def main
  ARGV.none? ? print_from_stdin : print_from_args(ARGV)
end

def print_from_stdin
  input_data = $stdin.read
  lines = input_data.split("\n")

  lines_num = lines.size.to_s
  words_num = lines.map { |line| line.split.size }.sum.to_s
  file_size = input_data.bytesize.to_s
  total_nums = [lines_num, words_num, file_size]

  width = calc_width(total_nums)

  print_total(total_nums, width)
  print "\n"
end

def print_from_args(files)
  lines_nums = calc_lines_nums(files)
  total_lines_nums = lines_nums.sum.to_s

  words_nums = calc_words_nums(files)
  total_words_nums = words_nums.sum.to_s

  file_sizes = calc_sizes(files)
  total_size = file_sizes.sum.to_s

  total_nums = [total_lines_nums, total_words_nums, total_size]
  width = calc_width(total_nums)

  files_info = [lines_nums.map(&:to_s), words_nums.map(&:to_s), file_sizes.map(&:to_s), files]
  formatted_info = files_info.transpose

  if files.size > 1
    print_info(formatted_info, width)
    print_total(total_nums, width)
    print " total\n"
  else
    print_info(formatted_info, width)
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
  width = nums.map(&:size).max
  width + 1 > DEFAULT_WIDTH ? width + 1 : DEFAULT_WIDTH
end

def print_info(files, width)
  output = ''
  is_option_none = OPTIONS.values.none?
  files.each do |file|
    output += file[0].rjust(width) if OPTIONS['l'] || is_option_none
    output += file[1].rjust(width) if OPTIONS['w'] || is_option_none
    output += file[2].rjust(width) if OPTIONS['c'] || is_option_none
    output += " #{file[3]}\n"
  end
  print output
end

def print_total(total_nums, width)
  output = ''
  is_option_none = OPTIONS.values.none?
  output += total_nums[0].rjust(width) if OPTIONS['l'] || is_option_none
  output += total_nums[1].rjust(width) if OPTIONS['w'] || is_option_none
  output += total_nums[2].rjust(width) if OPTIONS['c'] || is_option_none
  print output
end

main
