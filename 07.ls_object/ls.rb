# frozen_string_literal: true

require_relative 'ls_command'

def main
  ls = LsCommand.new
  ls.display_files
end

main
