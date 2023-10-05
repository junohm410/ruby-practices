# frozen_string_literal: true

require 'etc'

class ObtainedFile
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
  def file_size = @file_stat.chardev? || @file_stat.blockdev? ? device_file_num : @file_stat.size
  def updated_at = @file_stat.mtime

  def read_link
    File.readlink(name)
  end

  def symbolic_link?
    File.symlink?(name)
  end

  private

  def device_file_num
    major_num = @file_stat.rdev_major.to_s(16)
    minor_num = @file_stat.rdev_minor.to_s(16)
    minor_num.insert(0, '0') if minor_num.size == 1
    "0x#{major_num}0000#{minor_num}"
  end
end
