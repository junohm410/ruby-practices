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

point = frames.each.with_index.sum do |frame, i|
  next_frame = frames[i + 1]
  frame_after_next = frames[i + 2]
  if i < 9
    if frame[0] == 10
      if next_frame[0] == 10
        10 + frame_after_next[0] + frame.sum
      else
        next_frame.sum + frame.sum
      end
    elsif frame.sum == 10
      next_frame[0] + frame.sum
    else
      frame.sum
    end
  else
    frame.sum
  end
end

puts point
