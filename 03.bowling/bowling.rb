#!/usr/bin/env ruby

score = ARGV[0]

scores = score.split(',')

shots = []
scores.each do |score|
  if score == 'X'
    shots << 10
    shots << 0
  else
    shots << score.to_i
  end
end

frames = []
shots.each_slice(2) do |shot|
  frames << shot
end

total_score = 0
frames.each.with_index do |frame, i|
  next_frame = i + 1
  frame_after_next = i + 2
  if i < 9
    if frame[0] == 10
      if frames[next_frame][0] == 10
        total_score += 10 + frames[frame_after_next][0] + frame.sum
      else
        total_score += frames[next_frame].sum + frame.sum
      end
    elsif frame.sum == 10
      total_score += frames[next_frame][0] + frame.sum
    else
      total_score += frame.sum
    end
  else
    total_score += frame.sum
  end
end

puts total_score
