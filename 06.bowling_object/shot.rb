# frozen_string_literal: true

class Shot
  attr_reader :fallen_pin

  def initialize(fallen_pin)
    @fallen_pin = fallen_pin
  end

  def score
    fallen_pin.to_i
  end
end
