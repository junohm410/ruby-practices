require_relative 'shot'

class Frame
  attr_reader :first_shot, :second_shot

  def initialize(first_shot_mark, second_shot_mark = nil, third_shot_mark = nil)
    @first_shot = Shot.new(first_shot_mark)
    @second_shot = Shot.new(second_shot_mark)
    @third_shot = Shot.new(third_shot_mark)
  end

  def score
    [first_shot, second_shot, @third_shot].sum(&:score)
  end

  def strike?
    first_shot.mark == 'X'
  end

  def spare?
    [first_shot, second_shot].sum(&:score) == 10
  end
end
