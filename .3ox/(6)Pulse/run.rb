#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.1] created:[26.03.03]
# doc:[PARTIAL] modified:[26.03.09] auth:[3OX.AI]
# Pulse runtime dispatcher with graceful fallback when scripts are missing.

ROOT = File.expand_path('../..', __dir__)
SCRIPTS = File.join(ROOT, '.3ox', 'scripts')

command = ARGV[0]
args = ARGV[1..]

script_for = {
  'teleprompt' => 'teleprompt.rb',
  'analyze' => 'analyze.rb'
}

script_name = script_for[command]
if script_name.nil?
  puts "Usage: ruby .3ox/.vec3/rc/run.rb [teleprompt|analyze]"
  exit 1
end

script_path = File.join(SCRIPTS, script_name)
if File.exist?(script_path)
  load script_path
else
  puts "[pulse:fallback] #{command} invoked (scripts missing at #{SCRIPTS})"
  puts "[pulse:fallback] args=#{args.join(' ')}"
  puts '[pulse:fallback] Create .3ox/scripts/teleprompt.rb and analyze.rb to enable full behaviors.'
end
