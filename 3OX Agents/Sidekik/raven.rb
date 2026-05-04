#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.3.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# RAVEN SUITE — edge-driven supervisor for 3OX.Sidekik.
#
# Each invocation = one rotor edge. Drains the inbox, writes status,
# exits. NO loops. NO sleep. NO daemon. NO PID files. The rotor is
# the clock — TPW.SPIN (hex 0x003 / k00) drives Pulse (k02) edges,
# and either the systemd path-unit on .raven/inbox or the operator
# CLI invokes us per edge.

require 'json'
require 'time'
require 'fileutils'

CUBE_ROOT  = File.expand_path(__dir__)
RAVEN_ROOT = File.join(CUBE_ROOT, '.raven')
INBOX      = File.join(RAVEN_ROOT, 'inbox')
OUTBOX     = File.join(RAVEN_ROOT, 'outbox')
TAPE_DIR   = File.join(RAVEN_ROOT, 'tape')
TAPE_FILE  = File.join(TAPE_DIR, 'tape.jsonl')
PULSE_RT   = File.join(CUBE_ROOT, '.3ox', '(6)Pulse', 'runtime')
LOG_DIR    = File.join(PULSE_RT, 'logs')
LOG_FILE   = File.join(LOG_DIR, 'raven.log')

PULSE_RB   = File.join(CUBE_ROOT, '.3ox', '(6)Pulse', 'run.rb')

[INBOX, OUTBOX, TAPE_DIR, PULSE_RT, LOG_DIR].each { |d| FileUtils.mkdir_p(d) }

def now; Time.now.utc.iso8601; end
def log(msg); File.open(LOG_FILE, 'a') { |f| f.puts("[#{now}] #{msg}") }; end

def cycle
  intents = Dir.glob(File.join(INBOX, '*.intent.json')).size
  if intents.positive?
    log("edge: dispatch (n=#{intents})")
    system('ruby', PULSE_RB, 'dispatch') || log('dispatch returned non-zero')
  end
  system('ruby', PULSE_RB, 'status', out: File::NULL)
end

def status
  system('ruby', PULSE_RB, 'status')
end

def aliveness
  status_path = File.join(PULSE_RT, 'status.json')
  unless File.exist?(status_path)
    puts JSON.pretty_generate({ 'authoritative' => false, 'reason' => 'no_status_yet' })
    exit 1
  end
  data = JSON.parse(File.read(status_path)) rescue {}
  pulse_ok  = data['updated_at'] && data['services'].is_a?(Hash)
  tape_ok   = File.exist?(TAPE_FILE)
  warden_ok = File.exist?(File.join(CUBE_ROOT, '.3ox', '(3)Rules', 'limits.toml'))
  canon_ok  = File.exist?(File.join(CUBE_ROOT, '.3ox', '_meta', 'WHOAMI.md')) &&
              File.exist?(File.join(CUBE_ROOT, '.3ox', '_meta', 'SESSION.CHECKPOINT.toml'))
  valid     = pulse_ok && tape_ok && warden_ok
  authoritative = valid && canon_ok
  report = {
    'agent' => '3OX.Sidekik', 'suite' => 'Raven', 'at' => now,
    'invariants' => {
      'pulse' => !!pulse_ok, 'tape' => !!tape_ok, 'warden' => !!warden_ok,
      'canon_source' => !!canon_ok, 'valid_box3' => !!valid,
      'authoritative' => !!authoritative
    }
  }
  puts JSON.pretty_generate(report)
  exit(authoritative ? 0 : 1)
end

cmd = ARGV[0]
case cmd
when 'tick', 'edge', 'once', nil then cycle; status
when 'status'                    then status
when 'aliveness'                 then aliveness
else
  puts <<~USAGE
    Usage: ruby raven.rb [tick|edge|once|status|aliveness]

    tick | edge | once   one rotor edge: dispatch + status (default)
    status               print latest status snapshot
    aliveness            local Box-aliveness verdict (exit 0 = authoritative)

    NO loops, NO sleep, NO daemon. The rotor is the clock.
    Wire the edge via:
      - systemd path-unit on .raven/inbox  (raven.path → raven.service)
      - operator CLI: ./sidekik tick
      - rotor tail in TelePromptR/merge.sh
  USAGE
  exit 1
end
