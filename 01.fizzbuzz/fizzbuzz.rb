#!/usr/bin/env ruby

(1..20).each do | num |
  if num % 3 == 0
    if num % 5 == 0
      puts "FizzBuzz"
    else 
      puts "Fizz"
    end
  elsif num % 5 == 0
    puts "Buzz"
  else
    puts num
  end
end

