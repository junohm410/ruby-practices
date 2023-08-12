#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

DEFAULT_WIDTH = 8

def main
  options = ARGV.getopts('lwc')
  ARGV.none? ? print_from_stdin(options) : print_from_args(ARGV, options)
end

def print_from_stdin(options)
  File.open('ls_result', 'w') { |file| file.puts $stdin.read }
  files_info = files_info(['ls_result'])
  File.delete('ls_result')

  print_total(files_info[:total_nums], options)
  print "\n"
end

def print_from_args(files, options)
  files_info = files_info(files)

  if files.size > 1
    print_info(files_info[:lines_words_sizes_info], files_info[:total_nums], options)
    print_total(files_info[:total_nums], options)
    print " total\n"
  else
    print_info(files_info[:lines_words_sizes_info], files_info[:total_nums], options)
  end
end

def files_info(files)
  lines_nums = calc_lines_nums(files)
  total_lines_nums = lines_nums.sum

  words_nums = calc_words_nums(files)
  total_words_nums = words_nums.sum

  file_sizes = calc_sizes(files)
  total_size = file_sizes.sum

  {
    lines_words_sizes_info: [lines_nums, words_nums, file_sizes, files].transpose,
    total_nums: [total_lines_nums, total_words_nums, total_size]
  }
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

def print_info(files, total_nums, options)
  width = calc_width(total_nums)
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

def print_total(total_nums, options)
  width = calc_width(total_nums)
  output = ''
  is_option_none = options.values.none?
  output += total_nums[0].to_s.rjust(width) if options['l'] || is_option_none
  output += total_nums[1].to_s.rjust(width) if options['w'] || is_option_none
  output += total_nums[2].to_s.rjust(width) if options['c'] || is_option_none
  print output
end

main
