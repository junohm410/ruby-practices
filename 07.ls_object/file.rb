# frozen_string_literal: true

require 'etc'

class File
  SUID = '4'
  SGID = '2'
  STICKY_BIT = '1'

  OWNER = 0
  GROUP = 1
  OTHER_USER = 2

  attr_reader :name, :hard_links_count, :owner, :group, :file_size, :updated_at, :block_size, :file_mode

  def initialize(file_name)
    file_stat = File.stat(file_name)

    @name = file_name
    @hard_links_count = file_stat.nlink
    @owner = Etc.getpwuid(file_stat.uid).name
    @group = Etc.getgrgid(file_stat.gid).name
    @file_size = file_stat.chardev? || file_stat.blockdev? ? file.device_file_num : file_stat.size
    @updated_at = file_stat.mtime
    @block_size = file_stat.blocks
    @file_mode = file_stat.mode
    @file_stat = file_stat
  end

  def format_file_mode
    octal_mode = @file_mode.to_s(8)
    octal_mode.insert(0, '0') if octal_mode.size == 5
    file_type = octal_mode[0..1]
    special_authority = octal_mode[2]
    rwx_modes = octal_mode[3..5]
    format_file_type(file_type) + format_right(rwx_modes, special_authority)
  end

  def device_file_num
    major_num = @file_stat.rdev_major.to_s(16)
    minor_num = @file_stat.rdev_minor.to_s(16)
    minor_num.insert(0, '0') if minor_num.size == 1
    "0x#{major_num}0000#{minor_num}"
  end

  private

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

  def format_right(modes, authority)
    formatted_right = ''
    modes.each_char.with_index do |mode, i|
      right = ''
      right += format_mode(mode)

      right = set_sugid(right) if authority == SUID && i == OWNER
      right = set_sugid(right) if authority == SGID && i == GROUP
      right = set_sticky_bit(right) if authority == STICKY_BIT && i == OTHER_USER
      formatted_right += right
    end
    formatted_right
  end

  def format_mode(mode)
    {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }[mode]
  end

  def set_sugid(right)
    right[-1] == 'x' ? right.gsub(/x$/, 's') : right.gsub(/-$/, 'S')
  end

  def set_sticky_bit(right)
    right[-1] == 'x' ? right.gsub(/x$/, 't') : right.gsub(/-$/, 'T')
  end
end

# file = File.new('ls_command.rb')
# puts file.name, file.hard_links_count, file.owner, file.group, file.file_size, file.updated_at, file.block_size, file.file_mode
# puts file.format_file_mode
