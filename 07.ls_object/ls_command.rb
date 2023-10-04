# frozen_string_literal: true

require 'optparse'
require_relative 'file'
require_relative 'formatter'
require_relative 'short_formatter'
require_relative 'long_formatter'

class LsCommand
  NUMBER_OF_COLUMNS = 3

  def initialize
    @options = ARGV.getopts('arl')
    flag = @options['a'] ? File::FNM_DOTMATCH : 0
    file_names = Dir.glob('*', flag)
    file_names = file_names.reverse if @options['r']
    @files = file_names.map { |file_name| OwnedFile.new(file_name) }
  end

  def display_files
    return display_files_in_detail if @options['l']

    formatter = ShortFormatter.new(@files)
    formatted_files = formatter.format_files
    file_names = @files.map(&:name)
    file_name_width = Formatter.find_longest_string_length(file_names)

    formatted_files.each do |row_files|
      row_files.each { |file| file == '' ? print(file) : print("#{file.name.ljust(file_name_width)} ") }
      print "\n"
    end
  end

  private

  def display_files_in_detail
    formatter = LongFormatter.new(@files)
    formatted_files = formatter.format_files

    puts "total #{formatter.calculate_total_block_sizes}"
    formatted_files.each { |file| puts file }
  end
end
