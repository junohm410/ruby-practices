# frozen_string_literal: true

require 'optparse'
require_relative 'file'

class LsCommand
  NUMBER_OF_COLUMNS = 3

  def initialize
    @options = ARGV.getopts('arl')
    flag = @options['a'] ? File::FNM_DOTMATCH : 0
    file_names = Dir.glob('*', flag)
    file_names = file_names.reverse if @options['r']
    @files = file_names.map { |file_name| File.new(file_name) }
    @width_file_name = printing_width(file_names)
  end

  def display_files
    return print_files_l if @options['l']

    files = format_files(number_of_displayed_rows)
    print_files(files, @width_file_name)
  end

  private

  def printing_width(object)
    object.map(&:size).max
  end

  def number_of_displayed_rows
    number_of_files = @files.size
    number_of_files.ceildiv(NUMBER_OF_COLUMNS)
  end

  def format_files(number_of_rows)
    cols_of_files = []
    @files.each_slice(number_of_rows) do |col_of_files|
      cols_of_files << col_of_files
    end

    last_col = cols_of_files.last
    last_col << '' until last_col.size == number_of_rows

    cols_of_files.transpose
  end

  def print_files(formatted_file, width)
    formatted_file.each do |files|
      files.each do |file|
        if file == ''
          print file
        else
          print "#{file.name.ljust(width)} "
        end
      end
      print "\n"
    end
  end

  def print_files_l
    width_uname = printing_width(user_names)
    width_gname = printing_width(group_names)
    width_link = printing_width(hard_links)
    width_size = printing_width(file_sizes)

    print "total #{total_blocks}\n"
    @files.each do |file|
      mode = file.format_file_mode
      link = file.hard_links_count.to_s
      size = file.file_size.to_s
      updated_at = file.updated_at.strftime('%-m %_d %H:%M')
      owner = file.owner
      group = file.group

      print "#{mode}  #{link.rjust(width_link)} #{owner.ljust(width_uname)}  #{group.rjust(width_gname)}  #{size.rjust(width_size)}  #{updated_at} #{file.name}"
      print "\n"
    end
  end

  def user_names
    @files.map(&:owner)
  end

  def group_names
    @files.map(&:group)
  end

  def hard_links
    @files.map { |file| file.hard_links_count.to_s }
  end

  def file_sizes
    @files.map { |file| file.file_size.to_s }
  end

  def total_blocks
    @files.sum(&:block_size)
  end
end
