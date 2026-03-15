#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.03.13]
# doc:[PARTIAL] modified:[26.03.13] auth:[3OX.AI]
# Money.Bagz analyze — budget analysis

def run
  require 'fileutils'
  out = File.expand_path('../../!0UT.BUDGET', __dir__)
  FileUtils.mkdir_p(out)
  puts "analyze complete"
end
