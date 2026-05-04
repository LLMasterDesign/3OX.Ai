#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik triage — classify intent and route.

require 'json'
require 'time'
require 'fileutils'

ROOT       = File.expand_path('../..', __dir__)
ROUTES     = JSON.parse(File.read(File.join(ROOT, '.3ox', '(5)Links', 'routes.json')))
RAVEN_ROOT = File.join(ROOT, '.raven')
INBOX      = File.join(RAVEN_ROOT, 'inbox')
OUTBOX     = File.join(RAVEN_ROOT, 'outbox')
TAPE_DIR   = File.join(RAVEN_ROOT, 'tape')
TAPE_FILE  = File.join(TAPE_DIR, 'tape.jsonl')

[INBOX, OUTBOX, TAPE_DIR].each { |d| FileUtils.mkdir_p(d) }

text = ARGV.join(' ').strip
text = ARGF.read.strip if text.empty? && !$stdin.tty?

if text.empty?
  warn "[triage] no input; usage: triage.rb 'free text intent'"
  exit 2
end

# Match keys against stems (strip trailing 's'), so "bill" hits "bills".
lc = text.downcase
key = ROUTES['intent_to_subagent'].keys.find do |k|
  stem = k.sub(/s$/, '')
  lc.include?(k) || lc.split(/\W+/).include?(stem)
end || 'note'
target = ROUTES.dig('intent_to_subagent', key) || 'self'

intent_id = "sk.i.#{Time.now.utc.strftime('%Y%m%dT%H%M%S')}-#{rand(36**4).to_s(36)}"
record = {
  'id' => intent_id,
  'kind' => 'intent.classified',
  'created_at' => Time.now.utc.iso8601,
  'operator' => ENV['SIDEKIK_OPERATOR'] || 'lucius',
  'text' => text,
  'classified_key' => key,
  'route_to' => target
}

File.open(TAPE_FILE, 'a') { |f| f.puts(JSON.generate(record)) }
File.write(File.join(INBOX, "#{intent_id}.intent.json"), JSON.pretty_generate(record))
puts JSON.pretty_generate(record)
