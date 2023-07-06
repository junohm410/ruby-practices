#!/usr/bin/env ruby

require 'date'
require 'optparse'

options = ARGV.getopts("m:y:")
month = options["m"].to_i
year = options["y"].to_i

if month == 0
  month = Date.today.month.to_i
end

if year == 0
  year = Date.today.year.to_i
end

first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)

days = first_day..last_day

def print_day(day)
  print day.day.to_s.rjust(2).ljust(3)
end

puts "      #{month}月 #{year}"
puts "日 月 火 水 木 金 土 "
print "\s" * (days.first.wday * 3)
days.each do |day|
  print_day(day)
  puts if day.saturday?
end
puts
