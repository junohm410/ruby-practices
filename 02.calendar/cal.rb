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

days = first_day.day..last_day.day

wd_counter = first_day.wday
puts  "      #{month}月 #{year}"
puts "日 月 火 水 木 金 土 "
print "\s" * (wd_counter * 2) + "\s" * wd_counter
days.each do |day|
  if day < 10
    print " #{day} "
  else
    print "#{day} "
  end
  wd_counter += 1
  if wd_counter % 7 == 0
    print "\n"
  end
end
