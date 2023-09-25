# frozen_string_literal: true

require_relative 'frame'

class Game
  FINAL_FRAME = 10
  SHOTS_PER_NORMAL_FRAME = 2

  def initialize(game_result)
    fallen_pins = game_result.split(',')
    @frames = []
    same_frame_pins = []
    fallen_pins.each do |fallen_pin|
      current_frame = @frames.size + 1
      organize_same_frame_pins(fallen_pin, same_frame_pins, current_frame)
      if @frames.size < (FINAL_FRAME - 1) && same_frame_pins.size == SHOTS_PER_NORMAL_FRAME
        @frames << Frame.new(*same_frame_pins)
        same_frame_pins = []
      end
    end
    @frames << Frame.new(*same_frame_pins)
  end

  def score
    @frames.each_with_index.sum do |current_frame, i|
      next_frame = @frames[i + 1]
      after_next_frame = @frames[i + 2]
      if i < (FINAL_FRAME - 1)
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
    return current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score if index == (FINAL_FRAME - 2)

    if next_frame.strike?
      current_frame.score + next_frame.score + after_next_frame.first_shot.score
    else
      current_frame.score + next_frame.first_shot.score + next_frame.second_shot.score
    end
  end

  def calculate_spare_bonus(current_frame, next_frame)
    current_frame.score + next_frame.first_shot.score
  end

  def organize_same_frame_pins(fallen_pin, same_frame_pins, current_frame)
    if fallen_pin == 'X'
      same_frame_pins << '10'
      same_frame_pins << nil if current_frame < FINAL_FRAME
    else
      same_frame_pins << fallen_pin
    end
  end
end
