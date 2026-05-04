#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik note — append a free-form note onto the tape.

require 'json'
require 'time'
require 'fileutils'

ROOT      = File.expand_path('../..', __dir__)
TAPE_DIR  = File.join(ROOT, '.raven', 'tape')
TAPE_FILE = File.join(TAPE_DIR, 'tape.jsonl')
FileUtils.mkdir_p(TAPE_DIR)

text = ARGV.join(' ').strip
text = ARGF.read.strip if text.empty? && !$stdin.tty?
abort "[note] empty note refused" if text.empty?

record = {
  'id' => "sk.n.#{Time.now.utc.strftime('%Y%m%dT%H%M%S')}-#{rand(36**4).to_s(36)}",
  'kind' => 'note',
  'created_at' => Time.now.utc.iso8601,
  'operator' => ENV['SIDEKIK_OPERATOR'] || 'lucius',
  'text' => text
}

File.open(TAPE_FILE, 'a') { |f| f.puts(JSON.generate(record)) }
puts JSON.pretty_generate(record)
