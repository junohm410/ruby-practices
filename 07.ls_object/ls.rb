# frozen_string_literal: true

require_relative 'ls_command'

def main
  options = ARGV.getopts('arl')
  flag = options['a'] ? File::FNM_DOTMATCH : 0
  file_names = options['r'] ? Dir.glob('*', flag).reverse : Dir.glob('*', flag)
  is_l_option_valid = options['l']
  ls_command = LsCommand.new(file_names, is_l_option_valid)
  ls_command.display_files
end

main
