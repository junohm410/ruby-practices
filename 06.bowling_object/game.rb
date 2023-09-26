# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(game_result)
    @frames = Frame.organize_all_frames(game_result)
  end

  def score
    @frames.each_with_index.sum do |current_frame, i|
      next_frame = @frames[i + 1]
      after_next_frame = @frames[i + 2]
      if i < (Frame::FINAL_FRAME - 1)
        if current_frame.strike?
          calculate_strike_bonus(current_frame, next_frame, after_next_frame, i)
        elsif current_frame.spare?
          calculate_spare_bonus(current_frame, next_frame)
        else
          current_frame.score
        end
      else
        current_frame.score
      end
    end
  end

  private

  def calculate_strike_bonus(current_frame, next_frame, after_next_frame, index)
    return current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score if index == (Frame::FINAL_FRAME - 2)

    if next_frame.strike?
      current_frame.score + next_frame.score + after_next_frame.first_shot.score
    else
      current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score
    end
  end

  def calculate_spare_bonus(current_frame, next_frame)
    current_frame.score + next_frame.first_shot.score
  end
end
