#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.2.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik dispatch — drain inbox, fan out via TPR, receipt.
#
# Architectural note: agents do NOT speak Telegram. Sidekik writes a
# *TPR routing receipt* into !0UT.SIDEKIK/tpr/handoff/. On the VPS,
# TelePromptR consumes those receipts and re-routes the intent into
# the correct sub-agent topic; speaker-mesh handles inference.

require 'json'
require 'time'
require 'fileutils'

ROOT       = File.expand_path('../..', __dir__)
ROUTES     = JSON.parse(File.read(File.join(ROOT, '.3ox', '(5)Links', 'routes.json')))
RAVEN_ROOT = File.join(ROOT, '.raven')
INBOX      = File.join(RAVEN_ROOT, 'inbox')
OUTBOX     = File.join(RAVEN_ROOT, 'outbox')
TAPE_FILE  = File.join(RAVEN_ROOT, 'tape', 'tape.jsonl')

TPR_DIR    = File.join(ROOT, ROUTES.dig('routes', 'tpr') || '!0UT.SIDEKIK/tpr')
HANDOFF    = File.join(TPR_DIR, 'handoff')

[INBOX, OUTBOX, HANDOFF, File.dirname(TAPE_FILE)].each { |d| FileUtils.mkdir_p(d) }

drained = 0
handoffs = 0

Dir.glob(File.join(INBOX, '*.intent.json')).sort.each do |path|
  intent  = JSON.parse(File.read(path))
  target  = intent['route_to'] || 'self'
  subdef  = ROUTES.dig('subagents', target) || {}

  if target == 'self'
    reply_text = "[dispatch] handled by self (note/plan/status): #{intent['text']}"
  else
    handoff_id   = intent['id'].sub('sk.i.', 'sk.h.')
    handoff_path = File.join(HANDOFF, "#{handoff_id}.handoff.json")
    handoff = {
      'id'           => handoff_id,
      'kind'         => 'tpr.handoff',
      'in_reply_to'  => intent['id'],
      'from_agent'   => ROUTES['agent'] || '3OX.Sidekik',
      'to_agent'     => target,
      'subagent_path'=> subdef['path'],
      'topics_hint'  => subdef['topics'] || [],
      'classified_key' => intent['classified_key'],
      'text'         => intent['text'],
      'created_at'   => Time.now.utc.iso8601,
      'consumer'     => 'TelePromptR',
      'merge_via'    => 'TelePromptR/<TPR_ZENS3N>/merge.sh',
      'speaker_unit' => 'speaker-mesh.service'
    }
    File.write(handoff_path, JSON.pretty_generate(handoff))
    handoffs += 1
    reply_text = "[dispatch] TPR handoff written for #{target} (#{handoff_path.sub(ROOT + '/', '')})"
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

puts JSON.pretty_generate({
  'drained'  => drained,
  'handoffs' => handoffs,
  'at'       => Time.now.utc.iso8601
})
