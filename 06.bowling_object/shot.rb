# frozen_string_literal: true

class Shot
  attr_reader :pinfall

  def initialize(pinfall)
    @pinfall = pinfall
  end

  def score
    return 10 if pinfall == 'X'

    pinfall.to_i
  end
end
