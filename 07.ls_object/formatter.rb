# frozen_string_literal: true

class Formatter
  def initialize(files)
    @files = files
  end

  def self.find_longest_string_length(file_prop_strings)
    file_prop_strings.map(&:size).max
  end
end
