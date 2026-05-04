#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik status — emit a status snapshot for the cube + Raven Suite.

require 'json'
require 'time'
require 'fileutils'

ROOT       = File.expand_path('../..', __dir__)
RAVEN_ROOT = File.join(ROOT, '.raven')
INBOX      = File.join(RAVEN_ROOT, 'inbox')
OUTBOX     = File.join(RAVEN_ROOT, 'outbox')
TAPE_FILE  = File.join(RAVEN_ROOT, 'tape', 'tape.jsonl')
PULSE_RT   = File.join(ROOT, '.3ox', '(6)Pulse', 'runtime')
STATUS     = File.join(PULSE_RT, 'status.json')

[INBOX, OUTBOX, File.dirname(TAPE_FILE), PULSE_RT].each { |d| FileUtils.mkdir_p(d) }

inbox_count  = Dir.glob(File.join(INBOX, '*.intent.json')).size
outbox_count = Dir.glob(File.join(OUTBOX, '*.reply.json')).size
tape_lines   = File.exist?(TAPE_FILE) ? File.foreach(TAPE_FILE).count : 0

snapshot = {
  'updated_at' => Time.now.utc.iso8601,
  'agent' => '3OX.Sidekik',
  'suite' => 'Raven',
  'slot'  => 'E043',
  'mode'  => inbox_count.zero? ? 'idle' : 'active',
  'queue_depth' => inbox_count,
  'active_job' => nil,
  'last_completed_job' => { 'status' => tape_lines.positive? ? 'completed' : 'none' },
  'services' => {
    'spark' => 'idle', 'brains' => 'idle', 'rules' => 'idle',
    'toolkit' => 'idle', 'links' => 'idle', 'pulse' => 'watching'
  },
  'raven' => {
    'inbox' => inbox_count,
    'outbox' => outbox_count,
    'tape_lines' => tape_lines
  }
}

File.write(STATUS, JSON.pretty_generate(snapshot))
puts JSON.pretty_generate(snapshot)
