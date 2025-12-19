#!/usr/bin/env ruby
# Sirius Clock Calculator
# Format: ⧗-YY.SSS (year, 3-digit day number since reset)

RESET_DATE = Time.new(2025, 8, 8)

def sirius_time
  now = Time.now
  days = ((now - RESET_DATE) / 86400).to_i
  year = now.year % 100
  "⧗-#{year}.#{days.to_s.rjust(3, '0')}"
end

# Command line usage
if __FILE__ == $0
  puts sirius_time
end

