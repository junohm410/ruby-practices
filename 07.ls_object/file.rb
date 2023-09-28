# frozen_string_literal: true

class File
  attr_reader :name

  def initialize(file_name)
    @name = file_name
  end
end
