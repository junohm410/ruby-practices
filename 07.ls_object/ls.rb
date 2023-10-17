# frozen_string_literal: true

require_relative 'ls_command'

def main
  options = ARGV.getopts('arl')
  flag = options['a'] ? File::FNM_DOTMATCH : 0
  file_names = Dir.glob('*', flag)
  is_r_option_valid = options['r']
  is_l_option_valid = options['l']
  ls_command = LsCommand.new(file_names, is_r_option_valid, is_l_option_valid)
  ls_command.display_files
end

main
