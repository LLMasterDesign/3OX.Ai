#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik pulse dispatcher — thin shim into scripts/.

SCRIPT_DIR = File.expand_path('../scripts', __dir__)

cmd = ARGV[0] || 'status'
args = ARGV[1..] || []

routes = {
  'triage'   => 'triage.rb',
  'dispatch' => 'dispatch.rb',
  'note'     => 'note.rb',
  'status'   => 'status.rb',
  'analyze'  => 'triage.rb',
  'teleprompt' => 'triage.rb'
}

script = routes[cmd]
unless script
  puts "Usage: ruby .3ox/(6)Pulse/run.rb [triage|dispatch|note|status|analyze|teleprompt] [args...]"
  exit 1
end

path = File.join(SCRIPT_DIR, script)
unless File.exist?(path)
  puts "[pulse:fallback] #{cmd} invoked, but #{path} missing"
  exit 0
end

ARGV.replace(args)
load path
