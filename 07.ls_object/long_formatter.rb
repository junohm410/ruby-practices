# frozen_string_literal: true

require_relative 'formatter'

class LongFormatter < Formatter
  SUID = '4'
  SGID = '2'
  STICKY_BIT = '1'

  OWNER = 0
  GROUP = 1
  OTHER_USER = 2

  DISPLAYED_DATE_FORMAT = '%-m %_d %H:%M'
  DISPLAYED_DATE_WIDTH = 12

  def format_files
    longest_hard_links_string_length = Formatter.find_longest_string_length(organize_all_hard_links_counts)
    longest_owner_string_length = Formatter.find_longest_string_length(organize_all_owners)
    longest_group_string_length = Formatter.find_longest_string_length(organize_all_groups)
    longest_file_size_string_length = Formatter.find_longest_string_length(organize_all_file_sizes)
    formatted_files =
      @files.map do |file|
        formatted_file_mode = format_file_mode(file.file_mode)
        hard_links_count = file.hard_links_count.to_s
        updated_at = file.updated_at.strftime(DISPLAYED_DATE_FORMAT)
        formatted_file = ''
        formatted_file += "#{formatted_file_mode}  #{hard_links_count.rjust(longest_hard_links_string_length)} "
        formatted_file += "#{file.owner.ljust(longest_owner_string_length)}  #{file.group.rjust(longest_group_string_length)}  "
        formatted_file += "#{file.file_size.to_s.rjust(longest_file_size_string_length)}#{updated_at.rjust(DISPLAYED_DATE_WIDTH)} #{file.name}"
        formatted_file += " -> #{file.read_link}" if file.symbolic_link?
        formatted_file
      end
    formatted_files.unshift("total #{calculate_total_block_sizes}")
  end

  private

  def organize_all_hard_links_counts
    @files.map { |file| file.hard_links_count.to_s }
  end

  def organize_all_owners
    @files.map(&:owner)
  end

  def organize_all_groups
    @files.map(&:group)
  end

  def organize_all_file_sizes
    @files.map { |file| file.file_size.to_s }
  end

  def format_file_mode(file_mode)
    octal_mode = file_mode.to_s(8)
    octal_mode.insert(0, '0') if octal_mode.size == 5
    file_type = octal_mode[0..1]
    special_authority = octal_mode[2]
    rwx_modes = octal_mode[3..5]
    format_file_type(file_type) + format_file_right(rwx_modes, special_authority)
  end

  def format_file_type(file_type)
    {
      '01' => 'p',
      '02' => 'c',
      '04' => 'd',
      '06' => 'b',
      '10' => '-',
      '12' => 'l',
      '14' => 's'
    }[file_type]
  end

  def format_file_right(rwx_modes, special_authority)
    formatted_file_right = ''
    rwx_modes.each_char.with_index do |rwx_mode, i|
      formatted_rwx_mode = format_rwx_mode(rwx_mode)
      formatted_rwx_mode = apply_suid_and_sgid(formatted_rwx_mode) if special_authority == SUID && i == OWNER
      formatted_rwx_mode = apply_suid_and_sgid(formatted_rwx_mode) if special_authority == SGID && i == GROUP
      formatted_rwx_mode = apply_sticky_bit(formatted_rwx_mode) if special_authority == STICKY_BIT && i == OTHER_USER
      formatted_file_right += formatted_rwx_mode
    end
    formatted_file_right
  end

  def format_rwx_mode(rwx_mode)
    {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }[rwx_mode]
  end

  def apply_suid_and_sgid(formatted_rwx_mode)
    formatted_rwx_mode[-1] == 'x' ? formatted_rwx_mode.gsub(/x$/, 's') : formatted_rwx_mode.gsub(/-$/, 'S')
  end

  def apply_sticky_bit(formatted_rwx_mode)
    formatted_rwx_mode[-1] == 'x' ? formatted_rwx_mode.gsub(/x$/, 't') : formatted_rwx_mode.gsub(/-$/, 'T')
  end

  def calculate_total_block_sizes
    @files.sum(&:block_size)
  end
end
