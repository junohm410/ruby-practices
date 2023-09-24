# frozen_string_literal: true

require_relative 'frame'

class Game
  FINAL_FRAME = 10
  SHOTS_PER_NORMAL_FRAME = 2

  def initialize(pinfall_string)
    pinfalls = pinfall_string.split(',')
    @frames = []
    same_frame_pinfalls = []
    pinfalls.each do |pinfall|
      current_frame = @frames.size + 1
      organize_same_frame_pinfalls(pinfall, same_frame_pinfalls, current_frame)
      if @frames.size < (FINAL_FRAME - 1) && same_frame_pinfalls.size == SHOTS_PER_NORMAL_FRAME
        @frames << Frame.new(*same_frame_pinfalls)
        same_frame_pinfalls = []
      end
    end
    @frames << Frame.new(*same_frame_pinfalls)
  end

  def score
    @frames.each_with_index.sum do |current_frame, idx|
      next_frame = @frames[idx + 1]
      after_next_frame = @frames[idx + 2]
      if idx < (FINAL_FRAME - 1)
        if current_frame.strike?
          calculate_strike_bonus(current_frame, next_frame, after_next_frame, idx)
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

  def calculate_strike_bonus(current_frame, next_frame, after_next_frame, idx)
    return current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score if idx == (FINAL_FRAME - 2)

    if next_frame.strike?
      current_frame.score + next_frame.score + after_next_frame.first_shot.score
    else
      current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score
    end
  end

  def calculate_spare_bonus(current_frame, next_frame)
    current_frame.score + next_frame.first_shot.score
  end

  def organize_same_frame_pinfalls(pinfall, same_frame_pinfalls, current_frame)
    if pinfall == 'X'
      same_frame_pinfalls << '10'
      same_frame_pinfalls << '0' if current_frame < FINAL_FRAME
    else
      same_frame_pinfalls << pinfall
    end
  end
end
