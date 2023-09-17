# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(score)
    score_marks = score.split(',')
    @frames = []
    same_frame_marks = []
    score_marks.each do |mark|
      if @frames.length < 9
        if mark == 'X'
          @frames << Frame.new(mark)
        else
          same_frame_marks << mark
          if same_frame_marks.length == 2
            @frames << Frame.new(*same_frame_marks)
            same_frame_marks = []
          end
        end
      else
        same_frame_marks << mark
      end
    end
    @frames << Frame.new(*same_frame_marks)
  end

  def score
    @frames.each_with_index.sum do |current_frame, i|
      next_frame = @frames[i + 1]
      after_next_frame = @frames[i + 2]
      if i < 9
        if current_frame.strike?
          calculate_strike(current_frame, next_frame, after_next_frame, i)
        elsif current_frame.spare?
          calculate_spare(current_frame, next_frame)
        else
          current_frame.score
        end
      else
        current_frame.score
      end
    end
  end

  private

  def calculate_strike(current_frame, next_frame, after_next_frame, idx)
    return current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score if idx == 8

    if next_frame.strike?
      current_frame.score + next_frame.score + after_next_frame.first_shot.score
    else
      current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score
    end
  end

  def calculate_spare(current_frame, next_frame)
    current_frame.score + next_frame.first_shot.score
  end
end
