# frozen_string_literal: true

require 'optparse'
require_relative 'obtained_file'
require_relative 'short_formatter'
require_relative 'long_formatter'

class LsCommand
  def initialize(file_names, is_l_option_valid)
    @file_names = file_names
    @is_l_option_valid = is_l_option_valid
    formatter = @is_l_option_valid ? LongFormatter.new(@file_names) : ShortFormatter.new(@file_names)
    @formatted_files = formatter.format_files
  end

  def display_files
    @formatted_files.each { |files| puts files }
  end
end
