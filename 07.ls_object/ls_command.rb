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

    formatted_files.each { |row_files| puts row_files.join(' ') }
  end

  private

  def display_files_in_detail
    formatter = LongFormatter.new(@files)
    formatted_files = formatter.format_files

    puts "total #{formatter.calculate_total_block_sizes}"
    formatted_files.each { |file| puts file }
  end
end
