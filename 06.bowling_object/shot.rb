# frozen_string_literal: true

class Shot
  attr_reader :pinfall

  def initialize(pinfall)
    @pinfall = pinfall
  end

  def score
    pinfall.to_i
  end
end
