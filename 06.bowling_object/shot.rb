# frozen_string_literal: true

class Shot
  def initialize(fallen_pin)
    @fallen_pin = fallen_pin
  end

  def score
    @fallen_pin.to_i
  end
end
