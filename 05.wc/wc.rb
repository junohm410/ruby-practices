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

  num_of_lines = lines.size.to_s
  num_of_words = lines.map { |line| line.split.size }.sum.to_s
  file_size = input_data.bytesize.to_s
  total_nums = [num_of_lines, num_of_words, file_size]

  width = calc_width(total_nums)

  print_total(total_nums, width)
  print "\n"
end

def print_from_args(args)
  nums_of_lines = calc_nums_of_lines(args)
  total_nums_of_lines = nums_of_lines.sum.to_s

  nums_of_words = calc_nums_of_words(args)
  total_nums_of_words = nums_of_words.sum.to_s

  file_sizes = calc_sizes(args)
  total_size = file_sizes.sum.to_s

  total_nums = [total_nums_of_lines, total_nums_of_words, total_size]
  width = calc_width(total_nums)

  files_info = [nums_of_lines.map(&:to_s), nums_of_words.map(&:to_s), file_sizes.map(&:to_s), args]
  formatted_info = files_info.transpose

  if args.size > 1
    print_info(formatted_info, width)
    print_total(total_nums, width)
    print " total\n"
  else
    print_info(formatted_files, width)
  end
end

def calc_nums_of_lines(files)
  files.map do |file|
    lines = File.open(file, &:readlines)
    num_of_lines(lines)
  end
end

def calc_nums_of_words(files)
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

def num_of_lines(lines)
  num_of_lines = lines.size
  is_last_line_new_line = lines[-1] =~ /\n$/
  num_of_lines -= 1 unless is_last_line_new_line
  num_of_lines = 0 if lines.none?
  num_of_lines
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
