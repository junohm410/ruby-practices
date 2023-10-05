# frozen_string_literal: true

require 'optparse'
require_relative 'obtained_file'
require_relative 'formatter'
require_relative 'short_formatter'
require_relative 'long_formatter'

class LsCommand
  def initialize
    @options = ARGV.getopts('arl')
    flag = @options['a'] ? File::FNM_DOTMATCH : 0
    file_names = Dir.glob('*', flag)
    file_names = file_names.reverse if @options['r']
    @files = file_names.map { |file_name| ObtainedFile.new(file_name) }
    @formatter = @options['l'] ? LongFormatter.new(@files) : ShortFormatter.new(@files)
  end

  def display_files
    formatted_files = @formatter.format_files
    formatted_files.each { |files| puts files }
  end
end
