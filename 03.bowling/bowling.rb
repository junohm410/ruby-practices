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

frames = []
shots.each_slice(2) do |shot|
  frames << shot
end

point = 0
frames.each.with_index do |frame, i|
  next_frame = i + 1
  frame_after_next = i + 2
  point +=
    if i < 9
      if frame[0] == 10
        if frames[next_frame][0] == 10
          10 + frames[frame_after_next][0] + frame.sum
        else
          frames[next_frame].sum + frame.sum
        end
      elsif frame.sum == 10
        frames[next_frame][0] + frame.sum
      else
        frame.sum
      end
    else
      frame.sum
    end
end

puts point
