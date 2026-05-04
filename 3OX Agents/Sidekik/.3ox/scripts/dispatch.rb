#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik dispatch — drain inbox, fan out to sub-agents (or self), receipt.

require 'json'
require 'time'
require 'fileutils'

ROOT       = File.expand_path('../..', __dir__)
ROUTES     = JSON.parse(File.read(File.join(ROOT, '.3ox', '(5)Links', 'routes.json')))
RAVEN_ROOT = File.join(ROOT, '.raven')
INBOX      = File.join(RAVEN_ROOT, 'inbox')
OUTBOX     = File.join(RAVEN_ROOT, 'outbox')
TAPE_FILE  = File.join(RAVEN_ROOT, 'tape', 'tape.jsonl')

[INBOX, OUTBOX].each { |d| FileUtils.mkdir_p(d) }

drained = 0
Dir.glob(File.join(INBOX, '*.intent.json')).sort.each do |path|
  intent = JSON.parse(File.read(path))
  target = intent['route_to'] || 'self'

  reply_text =
    case target
    when 'money_bagz'
      "[dispatch] would invoke Money.Bagz with: #{intent['text']}"
    when 'vso_agent'
      "[dispatch] would invoke VSO.Agent with: #{intent['text']}"
    else
      "[dispatch] handled by self (note/plan/status): #{intent['text']}"
    end

  reply_id = intent['id'].sub('sk.i.', 'sk.r.')
  reply = {
    'id' => reply_id,
    'kind' => 'dispatch.reply',
    'in_reply_to' => intent['id'],
    'route_to' => target,
    'text' => reply_text,
    'completed_at' => Time.now.utc.iso8601,
    'status' => 'completed'
  }

  File.write(File.join(OUTBOX, "#{reply_id}.reply.json"), JSON.pretty_generate(reply))
  File.open(TAPE_FILE, 'a') { |f| f.puts(JSON.generate(reply)) }
  FileUtils.rm_f(path)
  drained += 1
end

puts JSON.pretty_generate({ 'drained' => drained, 'at' => Time.now.utc.iso8601 })
