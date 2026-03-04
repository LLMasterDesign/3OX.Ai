#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.01.02]
# doc:[COMPLETE] modified:[26.03.03] auth:[ZEN.PRO]
# Money.Bagz entry point — thin dispatcher

SCRIPT_DIR = File.join(File.dirname(__FILE__), "..", "scripts")

cmd = ARGV[0] || "analyze"
case cmd
when "analyze"
  load File.join(SCRIPT_DIR, "analyze.rb")
  run
when "alerts"
  load File.join(SCRIPT_DIR, "alerts.rb")
  run
when "teleprompt"
  load File.join(SCRIPT_DIR, "teleprompt.rb")
  run
when "budget-update"
  load File.join(SCRIPT_DIR, "budget-update.rb")
  run(ARGV[1])
else
  puts "Usage: ruby .3ox/(6)Pulse/run.rb [analyze|alerts|teleprompt|budget-update]"
end
