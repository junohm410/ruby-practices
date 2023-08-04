#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

NUMBER_OF_COLUMNS = 3

SUID = '4'
SGID = '2'
STICKY_BIT = '1'

OWNER = 0
GROUP = 1
OTHER_USER = 2

def make_file_stat(file_name)
  File.stat(file_name)
end

def octal_mode(file_stat)
  mode = file_stat.mode.to_s(8)
  mode.insert(0, '0') if mode.size == 5
  mode
end

def sticky_bit(right)
  right[-1] == 'x' ? right.gsub(/x$/, 't') : right.gsub(/-$/, 'T')
end

def sugid(right)
  right[-1] == 'x' ? right.gsub(/x$/, 's') : right.gsub(/-$/, 'S')
end

def type_checker(type_num)
  types = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }
  types[type_num]
end

def mode_checker(mode_num)
  modes = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }
  modes[mode_num]
end

def format_right(modes, authority)
  formated_right = ''
  modes.each_char.with_index do |mode, i|
    right = ''
    right += mode_checker(mode)

    right = sugid(right) if authority == SUID && i == OWNER
    right = sugid(right) if authority == SGID && i == GROUP
    right = sticky_bit(right) if authority == STICKY_BIT && i == OTHER_USER
    formated_right += right
  end
  formated_right
end

def format_mode(file_stat)
  mode = octal_mode(file_stat)
  file_type = mode[0..1]
  special_authority = mode[2]
  rwx_modes = mode[3..5]
  type_checker(file_type) + format_right(rwx_modes, special_authority)
end

def device_file_num(stat)
  major_num = stat.rdev_major.to_s(16)
  minor_num = stat.rdev_minor.to_s(16)
  minor_num.insert(0, '0') if minor_num.size == 1
  "0x#{major_num}0000#{minor_num}"
end

def user_names(stats)
  stats.map { |stat| Etc.getpwuid(stat.uid).name }
end

def group_names(stats)
  stats.map { |stat| Etc.getgrgid(stat.gid).name }
end

def hard_links(stats)
  stats.map { |stat| stat.nlink.to_s }
end

def file_sizes(stats)
  stats.map { |stat| stat.chardev? || stat.blockdev? ? device_file_num(stat) : stat.size.to_s }
end

def total_blocks(stats)
  stats.sum(&:blocks)
end

def printing_width(object)
  object.map(&:size).max
end

def print_files_l(files)
  files_stats =
    files.map { |file| File.symlink?(file) ? File.lstat(file) : make_file_stat(file) }

  width_uname = printing_width(user_names(files_stats))
  width_gname = printing_width(group_names(files_stats))
  width_link = printing_width(hard_links(files_stats))
  width_size = printing_width(file_sizes(files_stats))

  print "total #{total_blocks(files_stats)}\n"
  files_stats.each_with_index do |stat, i|
    mode = format_mode(stat)
    link = stat.nlink.to_s
    size = stat.chardev? || stat.blockdev? ? device_file_num(stat) : stat.size.to_s
    update_time = stat.mtime.strftime('%-m %_d %H:%M')
    user = Etc.getpwuid(stat.uid).name
    group = Etc.getgrgid(stat.gid).name

    print "#{mode}  #{link.rjust(width_link)} #{user.ljust(width_uname)}  #{group.rjust(width_gname)}  #{size.rjust(width_size)}  #{update_time} #{files[i]}"
    print " -> #{File.readlink(files[i])}" if File.symlink?(files[i])
    print "\n"
  end
end

def number_of_displayed_rows(files)
  number_of_files = files.size
  number_of_files.ceildiv(NUMBER_OF_COLUMNS)
end

def format_files(files, number_of_rows)
  cols_of_files = []
  files.each_slice(number_of_rows) do |col_of_files|
    cols_of_files << col_of_files
  end

  last_col = cols_of_files.last
  last_col << '' until last_col.size == number_of_rows

  cols_of_files.transpose
end

def print_files(formatted_file, width)
  formatted_file.each do |files|
    files.each { |file| print "#{file.ljust(width)} " }
    print "\n"
  end
end

def display_files
  options = ARGV.getopts('arl')

  flag = options['a'] ? File::FNM_DOTMATCH : 0
  files = Dir.glob('*', flag)
  files = files.reverse if options['r']

  return print_files_l(files) if options['l']

  width_per_file = printing_width(files)

  files = format_files(files, number_of_displayed_rows(files))

  print_files(files, width_per_file)
end

display_files
