# frozen_string_literal: true

require 'optparse'
require_relative 'file'

class LsCommand
  NUMBER_OF_COLUMNS = 3

  def initialize
    @options = ARGV.getopts('arl')
    flag = @options['a'] ? File::FNM_DOTMATCH : 0
    file_names = Dir.glob('*', flag)
    file_names = file_names.reverse if @options['r']
    @files = file_names.map { |file_name| OwnedFile.new(file_name) }
  end

  def self.find_longest_string_length(file_prop_strings)
    file_prop_strings.map(&:size).max
  end

  def display_files
    return display_files_in_detail if @options['l']

    formatted_files = format_files(count_displayed_rows)
    file_names = @files.map(&:name)
    file_name_width = LsCommand.find_longest_string_length(file_names)
    formatted_files.each do |row_files|
      row_files.each { |file| file == '' ? print(file) : print("#{file.name.ljust(file_name_width)} ") }
      print "\n"
    end
  end

  private

  def format_files(rows_count)
    files_cols = []
    @files.each_slice(rows_count) do |files_col|
      files_cols << files_col
    end

    last_col = files_cols.last
    last_col << '' until last_col.size == rows_count

    files_cols.transpose
  end

  def count_displayed_rows
    files_count = @files.size
    files_count.ceildiv(NUMBER_OF_COLUMNS)
  end

  def display_files_in_detail
    hard_links_count_width = LsCommand.find_longest_string_length(organize_all_hard_links_counts)
    owner_width = LsCommand.find_longest_string_length(organize_all_owners)
    group_width = LsCommand.find_longest_string_length(organize_all_groups)
    file_size_width = LsCommand.find_longest_string_length(organize_all_file_sizes)

    print "total #{calculate_total_block_sizes}\n"
    @files.each do |file|
      formatted_file_mode = file.format_file_mode
      hard_links_count = file.hard_links_count.to_s
      owner = file.owner
      group = file.group
      file_size = file.file_size.to_s
      updated_at = file.updated_at.strftime('%-m %_d %H:%M')

      print "#{formatted_file_mode}  #{hard_links_count.rjust(hard_links_count_width)} #{owner.ljust(owner_width)}  "
      print "#{group.rjust(group_width)}  #{file_size.rjust(file_size_width)}  #{updated_at} #{file.name}"
      print " -> #{file.read_link}" if file.symbolic_link?
      print "\n"
    end
  end

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

  def calculate_total_block_sizes
    @files.sum(&:block_size)
  end
end
