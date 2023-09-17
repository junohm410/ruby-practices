# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :first_shot, :second_shot

  def initialize(first_score_mark, second_score_mark = nil, third_score_mark = nil)
    @first_shot = Shot.new(first_score_mark)
    @second_shot = Shot.new(second_score_mark)
    @third_shot = Shot.new(third_score_mark)
  end

  def score
    [first_shot, second_shot, @third_shot].sum(&:score)
  end

  def strike?
    first_shot.score_mark == 'X'
  end

  def spare?
    [first_shot, second_shot].sum(&:score) == 10
  end
end
