# frozen_string_literal: true

require_relative 'shot'

class Frame
  FINAL_FRAME = 10
  SHOTS_PER_NORMAL_FRAME = 2

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

  def self.organize_all_frames(game_result)
    fallen_pins = game_result.split(',')
    frames = []
    same_frame_pins = []
    fallen_pins.each do |fallen_pin|
      current_frame = frames.size + 1
      Frame.organize_same_frame_pins(fallen_pin, same_frame_pins, current_frame)
      if frames.size < (FINAL_FRAME - 1) && same_frame_pins.size == SHOTS_PER_NORMAL_FRAME
        frames << Frame.new(*same_frame_pins)
        same_frame_pins = []
      end
    end
    frames << Frame.new(*same_frame_pins)
  end

  def self.organize_same_frame_pins(fallen_pin, same_frame_pins, current_frame)
    if fallen_pin == 'X'
      same_frame_pins << '10'
      same_frame_pins << nil if current_frame < FINAL_FRAME
    else
      same_frame_pins << fallen_pin
    end
  end
end
