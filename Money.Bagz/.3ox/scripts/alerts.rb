#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.03.13]
# doc:[PARTIAL] modified:[26.03.13] auth:[3OX.AI]
# Money.Bagz alerts — due date and budget alerts

def run
  out = File.expand_path('../../!0UT.BUDGET/alerts', __dir__)
  require 'fileutils'
  FileUtils.mkdir_p(out)
  puts "alerts complete"
end
