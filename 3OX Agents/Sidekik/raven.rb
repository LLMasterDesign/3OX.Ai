#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# RAVEN SUITE — Sidekik supervisor loop.
#
# Single-process, single-operator supervisor for 3OX.Sidekik.
# Polls .raven/inbox for intents, dispatches, refreshes status.
# This is the "always-on" face of the Suite when speaker-mesh /
# teleprompter aren't available locally.

require 'json'
require 'time'
require 'fileutils'
require 'optparse'

CUBE_ROOT  = File.expand_path(__dir__)
RAVEN_ROOT = File.join(CUBE_ROOT, '.raven')
INBOX      = File.join(RAVEN_ROOT, 'inbox')
OUTBOX     = File.join(RAVEN_ROOT, 'outbox')
TAPE_DIR   = File.join(RAVEN_ROOT, 'tape')
TAPE_FILE  = File.join(TAPE_DIR, 'tape.jsonl')
PULSE_RT   = File.join(CUBE_ROOT, '.3ox', '(6)Pulse', 'runtime')
LOG_DIR    = File.join(PULSE_RT, 'logs')
PID_FILE   = File.join(PULSE_RT, 'raven.pid')
LOG_FILE   = File.join(LOG_DIR, 'raven.log')

PULSE_RB   = File.join(CUBE_ROOT, '.3ox', '(6)Pulse', 'run.rb')

[INBOX, OUTBOX, TAPE_DIR, PULSE_RT, LOG_DIR].each { |d| FileUtils.mkdir_p(d) }

def now; Time.now.utc.iso8601; end
def log(msg); File.open(LOG_FILE, 'a') { |f| f.puts("[#{now}] #{msg}") }; end

def running?
  return false unless File.exist?(PID_FILE)
  pid = File.read(PID_FILE).to_i
  return false if pid <= 0
  Process.kill(0, pid); true
rescue Errno::ESRCH, Errno::EPERM
  false
end

def cycle
  intents = Dir.glob(File.join(INBOX, '*.intent.json')).size
  if intents.positive?
    log("dispatch start (n=#{intents})")
    system('ruby', PULSE_RB, 'dispatch') || log('dispatch returned non-zero')
  end
  system('ruby', PULSE_RB, 'status', out: File::NULL)
end

def loop_forever(interval)
  log("raven up (interval=#{interval}s)")
  trap('TERM') { log('raven term'); exit(0) }
  trap('INT')  { log('raven int');  exit(0) }
  loop do
    cycle
    sleep interval
  end
end

def start(interval)
  if running?
    puts "raven already running (pid=#{File.read(PID_FILE).strip})"
    return
  end
  pid = fork do
    Process.setsid
    out = File.open(LOG_FILE, 'a')
    $stdout.reopen(out); $stderr.reopen(out)
    $stdout.sync = true; $stderr.sync = true
    File.write(PID_FILE, Process.pid.to_s)
    begin
      loop_forever(interval)
    ensure
      FileUtils.rm_f(PID_FILE)
      log('raven down')
    end
  end
  Process.detach(pid)
  puts "raven started (pid=#{pid}, interval=#{interval}s)"
end

def stop
  unless running?
    puts 'raven not running'
    return
  end
  pid = File.read(PID_FILE).to_i
  Process.kill('TERM', pid)
  puts "raven stop signal sent to pid=#{pid}"
end

def status
  system('ruby', PULSE_RB, 'status')
end

def aliveness
  # Sidekik treats its own status.json as Pulse, .raven/tape as Tape,
  # and cube limits.toml as Warden. This is local aliveness — the root
  # repo aliveness check (.vec3/rc/run.rb) still owns kernel verdict.
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

interval = (ENV['RAVEN_INTERVAL'] || '5').to_i
cmd = ARGV[0]
case cmd
when 'start'     then start(interval)
when 'stop'      then stop
when 'status'    then status
when 'aliveness' then aliveness
when 'once'      then cycle; status
when 'tick'      then cycle
else
  puts <<~USAGE
    Usage: ruby raven.rb [start|stop|status|once|tick|aliveness]

    start      # detach supervisor loop (env RAVEN_INTERVAL=5)
    stop       # signal TERM to running supervisor
    status     # write + print latest status snapshot
    once       # one cycle (dispatch + status), then exit
    tick       # one dispatch+status cycle, no detach
    aliveness  # local Box-aliveness verdict for Sidekik
  USAGE
  exit 1
end
