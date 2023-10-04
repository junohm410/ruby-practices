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
    @formatter = @options['l'] ? LongFormatter.new(@files) : ShortFormatter.new(@files)
  end

  def display_files
    formatted_files = @formatter.format_files
    formatted_files.each { |files| puts files }
  end
end
