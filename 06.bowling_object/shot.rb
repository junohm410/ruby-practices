# frozen_string_literal: true

class Shot
  attr_reader :score_mark

  def initialize(score_mark)
    @score_mark = score_mark
  end

  def score
    return 10 if score_mark == 'X'

    score_mark.to_i
  end
end
