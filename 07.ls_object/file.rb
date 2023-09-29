# frozen_string_literal: true

require 'etc'

class OwnedFile
  SUID = '4'
  SGID = '2'
  STICKY_BIT = '1'

  OWNER = 0
  GROUP = 1
  OTHER_USER = 2

  attr_reader :name

  def initialize(file_name)
    @name = file_name
    @file_stat = File.symlink?(file_name) ? File.lstat(file_name) : File.stat(file_name)
  end

  def block_size = @file_stat.blocks
  def file_mode = @file_stat.mode
  def hard_links_count = @file_stat.nlink
  def owner = Etc.getpwuid(@file_stat.uid).name
  def group = Etc.getgrgid(@file_stat.gid).name
  def file_size = @file_stat.chardev? || @file_stat.blockdev? ? format_device_file_num : @file_stat.size
  def updated_at = @file_stat.mtime

  def format_file_mode
    octal_mode = file_mode.to_s(8)
    octal_mode.insert(0, '0') if octal_mode.size == 5
    file_type = octal_mode[0..1]
    special_authority = octal_mode[2]
    rwx_modes = octal_mode[3..5]
    format_file_type(file_type) + format_file_right(rwx_modes, special_authority)
  end

  def read_link
    File.readlink(name)
  end

  def symbolic_link?
    File.symlink?(name)
  end

  private

  def format_device_file_num
    major_num = @file_stat.rdev_major.to_s(16)
    minor_num = @file_stat.rdev_minor.to_s(16)
    minor_num.insert(0, '0') if minor_num.size == 1
    "0x#{major_num}0000#{minor_num}"
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
end
