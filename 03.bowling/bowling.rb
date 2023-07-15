#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]

scores = score.split(',')

shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

point = frames.each_with_index.sum do |current_frame, i|
  next_frame = frames[i + 1]
  after_next_frame = frames[i + 2]
  if i < 9
    if current_frame[0] == 10
      if next_frame[0] == 10
        current_frame.sum + next_frame[0] + after_next_frame[0]
      else
        current_frame.sum + next_frame.sum
      end
    elsif current_frame.sum == 10
      current_frame.sum + next_frame[0]
    else
      current_frame.sum
    end
  else
    current_frame.sum
  end
end

puts point
