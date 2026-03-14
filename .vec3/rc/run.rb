#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.03.13]
# doc:[PARTIAL] modified:[26.03.13] auth:[3OX.AI]
# RC runtime checks for Box aliveness contract invariants.

require 'json'
require 'digest'
require 'time'

ROOT = File.expand_path('../..', __dir__)
BOX_ROOT = File.join(ROOT, '.3ox')
PULSE_RUNTIME = File.join(BOX_ROOT, '(6)Pulse', 'runtime')
STATUS_FILE = File.join(PULSE_RUNTIME, 'status.json')
QUEUE_FILE = File.join(PULSE_RUNTIME, 'queue', 'jobs.json')
LIMITS_FILE = File.join(BOX_ROOT, '(3)Rules', 'limits.toml')
WHOAMI_FILE = File.join(BOX_ROOT, '_meta', 'WHOAMI.md')
SESSION_CHECKPOINT_FILE = File.join(BOX_ROOT, '_meta', 'SESSION.CHECKPOINT.toml')


def now
  Time.now.utc.iso8601
end

def load_json(path, fallback)
  return fallback unless File.exist?(path)

  JSON.parse(File.read(path))
rescue JSON::ParserError
  fallback
end

def hashed(path)
  Digest::SHA256.hexdigest(File.read(path))
end

def pulse_valid?
  status = load_json(STATUS_FILE, nil)
  status.is_a?(Hash) && status['updated_at'] && status['services'].is_a?(Hash)
end

def tape_valid?
  queue = load_json(QUEUE_FILE, nil)
  queue.is_a?(Hash) && queue['jobs'].is_a?(Array)
end

def warden_valid?
  File.exist?(LIMITS_FILE) && !File.read(LIMITS_FILE).strip.empty?
end

def canon_source?
  File.directory?(BOX_ROOT) && File.exist?(WHOAMI_FILE) && File.exist?(SESSION_CHECKPOINT_FILE)
end

def goal_reached?
  status = load_json(STATUS_FILE, {})
  status.dig('last_completed_job', 'status') == 'completed'
end

def aliveness_report
  report = {
    'timestamp' => now,
    'hashes' => {
      'status_sha256' => File.exist?(STATUS_FILE) ? hashed(STATUS_FILE) : nil,
      'queue_sha256' => File.exist?(QUEUE_FILE) ? hashed(QUEUE_FILE) : nil,
      'limits_sha256' => File.exist?(LIMITS_FILE) ? hashed(LIMITS_FILE) : nil
    },
    'invariants' => {
      'pulse' => pulse_valid?,
      'tape' => tape_valid?,
      'warden' => warden_valid?,
      'valid_box3' => false,
      'authoritative' => false,
      'goal_reached' => goal_reached?,
      'success' => false
    }
  }

  report['invariants']['valid_box3'] =
    report['invariants']['pulse'] && report['invariants']['tape'] && report['invariants']['warden']
  report['invariants']['authoritative'] = report['invariants']['valid_box3'] && canon_source?
  report['invariants']['success'] = report['invariants']['authoritative'] && report['invariants']['goal_reached']

  report
end

def check_aliveness
  report = aliveness_report
  puts JSON.pretty_generate(report)
  exit(report.dig('invariants', 'authoritative') ? 0 : 1)
end

command = ARGV[0]
case command
when 'aliveness'
  check_aliveness
else
  puts <<~USAGE
    Usage: ruby .vec3/rc/run.rb aliveness

    aliveness                  # evaluate Box aliveness contract invariants
  USAGE
  exit 1
end
