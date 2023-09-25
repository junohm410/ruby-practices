# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :first_shot, :second_shot

  def initialize(first_fallen_pin, second_fallen_pin = nil, third_fallen_pin = nil)
    @first_shot = Shot.new(first_fallen_pin)
    @second_shot = Shot.new(second_fallen_pin)
    @third_shot = Shot.new(third_fallen_pin)
  end

  def score
    [first_shot, second_shot, @third_shot].sum(&:score)
  end

  def strike?
    first_shot.fallen_pin == '10'
  end

  def spare?
    [first_shot, second_shot].sum(&:score) == 10 && !strike?
  end
end
