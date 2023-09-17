# frozen_string_literal: true

require_relative 'frame'

class Game
  FRAME_BEFORE_FINAL = 9
  SHOTS_PER_NORMAL_FRAME = 2

  FINAL_FRAME_IDX = 9
  FRAME_BEFORE_FINAL_IDX = 8

  def initialize(pinfall_string)
    pinfalls = pinfall_string.split(',')
    @frames = []
    same_frame_pinfalls = []
    pinfalls.each do |pinfall|
      if @frames.size < FRAME_BEFORE_FINAL
        if pinfall == 'X'
          @frames << Frame.new(pinfall)
        else
          same_frame_pinfalls << pinfall
          if same_frame_pinfalls.length == SHOTS_PER_NORMAL_FRAME
            @frames << Frame.new(*same_frame_pinfalls)
            same_frame_pinfalls = []
          end
        end
      else
        same_frame_pinfalls << pinfall
      end
    end
    @frames << Frame.new(*same_frame_pinfalls)
  end

  def score
    @frames.each_with_index.sum do |current_frame, idx|
      next_frame = @frames[idx + 1]
      after_next_frame = @frames[idx + 2]
      if idx < FINAL_FRAME_IDX
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
    return current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score if idx == FRAME_BEFORE_FINAL_IDX

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
