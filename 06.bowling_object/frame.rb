# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :first_shot, :second_shot

  def initialize(first_shot_pinfall, second_shot_pinfall = nil, third_shot_pinfall = nil)
    @first_shot = Shot.new(first_shot_pinfall)
    @second_shot = Shot.new(second_shot_pinfall)
    @third_shot = Shot.new(third_shot_pinfall)
  end

  def score
    [first_shot, second_shot, @third_shot].sum(&:score)
  end

  def strike?
    first_shot.pinfall == 'X'
  end

  def spare?
    [first_shot, second_shot].sum(&:score) == 10
  end
end
