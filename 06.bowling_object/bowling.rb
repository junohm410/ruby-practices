# frozen_string_literal: true

require_relative 'game'

def main
  game = Game.new(ARGV[0])
  puts game.score
end

main
