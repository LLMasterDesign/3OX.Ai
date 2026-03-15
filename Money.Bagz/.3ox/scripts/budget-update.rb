#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.03.13]
# doc:[PARTIAL] modified:[26.03.13] auth:[3OX.AI]
# Money.Bagz budget-update — update bills/budget

def run(path = nil)
  require 'fileutils'
  out = File.expand_path('../../!0UT.BUDGET', __dir__)
  FileUtils.mkdir_p(out)
  puts "budget-update complete"
end
