#!/usr/bin/env ruby
# status:[DRAFT] ver:[1.0.0] created:[26.03.03]
# doc:[PARTIAL] modified:[26.03.03] auth:[3OX.AI]
# Run template — agent entry point and dispatcher

AGENT_ROOT = File.expand_path('..', __dir__)
SCRIPTS    = File.join(AGENT_ROOT, '.3ox', 'scripts')

command = ARGV[0]
args    = ARGV[1..]

case command
when 'teleprompt'
  load File.join(SCRIPTS, 'teleprompt.rb')
when 'analyze'
  load File.join(SCRIPTS, 'analyze.rb')
else
  puts "Usage: ruby .3ox/run.rb [teleprompt|analyze]"
  exit 1
end
