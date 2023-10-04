require_relative 'formatter'

class LongFormatter < Formatter
  SUID = '4'
  SGID = '2'
  STICKY_BIT = '1'

  OWNER = 0
  GROUP = 1
  OTHER_USER = 2

  def format_files
    hard_links_count_width = Formatter.find_longest_string_length(organize_all_hard_links_counts)
    owner_width = Formatter.find_longest_string_length(organize_all_owners)
    group_width = Formatter.find_longest_string_length(organize_all_groups)
    file_size_width = Formatter.find_longest_string_length(organize_all_file_sizes)
    formatted_files =
      @files.map do |file|
        formatted_file_mode = format_file_mode(file.file_mode)
        hard_links_count = file.hard_links_count.to_s
        owner = file.owner
        group = file.group
        file_size = file.file_size.to_s
        updated_at = file.updated_at.strftime('%-m %_d %H:%M')
        name = file.name
        formatted_file = ''
        formatted_file += "#{formatted_file_mode}  #{hard_links_count.rjust(hard_links_count_width)} #{owner.ljust(owner_width)}  "
        formatted_file += "#{group.rjust(group_width)}  #{file_size.rjust(file_size_width)}#{updated_at.rjust(12)} #{name}"
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
      file_right = ''
      file_right += format_mode(rwx_mode)

      file_right = apply_suid_and_sgid(file_right) if special_authority == SUID && i == OWNER
      file_right = apply_suid_and_sgid(file_right) if special_authority == SGID && i == GROUP
      file_right = apply_sticky_bit(file_right) if special_authority == STICKY_BIT && i == OTHER_USER
      formatted_file_right += file_right
    end
    formatted_file_right
  end

  def format_mode(rwx_mode)
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

  def apply_suid_and_sgid(file_right)
    file_right[-1] == 'x' ? file_right.gsub(/x$/, 's') : file_right.gsub(/-$/, 'S')
  end

  def apply_sticky_bit(file_right)
    file_right[-1] == 'x' ? file_right.gsub(/x$/, 't') : file_right.gsub(/-$/, 'T')
  end

  def calculate_total_block_sizes
    @files.sum(&:block_size)
  end
end
