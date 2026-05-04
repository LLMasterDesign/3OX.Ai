#!/usr/bin/env ruby
# status:[ACTIVE] ver:[0.1.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# 3OX.Sidekik teleprompt — emit TPR fragment for TelePromptR merge.
#
# TPR (TelePromptR) is the *only* component that talks to Telegram.
# Agents emit two JSON fragments here, which TPR's merge.sh on the
# VPS folds into the master TPR.SPEAKER.MESH.json + TPR.ROUTE.MAP.json.
# After merge, `systemctl restart speaker-mesh` picks them up.

require 'json'
require 'time'
require 'fileutils'

ROOT       = File.expand_path('../..', __dir__)
ROUTES     = JSON.parse(File.read(File.join(ROOT, '.3ox', '(5)Links', 'routes.json')))
SPARK      = File.read(File.join(ROOT, '.3ox', '(1)Spark', 'sparkfile.md'))

# Output mirrors the Money.Bagz layout: agent_root/<routes.tpr>/{speaker,route}
TPR_DIR    = File.join(ROOT, ROUTES.dig('routes', 'tpr') || '!0UT.SIDEKIK/tpr')
SPEAKER    = File.join(TPR_DIR, 'TPR.SPEAKER.MESH.json')
ROUTE_MAP  = File.join(TPR_DIR, 'TPR.ROUTE.MAP.json')
RECEIPT    = File.join(TPR_DIR, 'TPR.RECEIPT.json')
FileUtils.mkdir_p(TPR_DIR)

agent       = ROUTES['agent']        || '3OX.Sidekik'
slot        = ROUTES['slot']         || 'E043'
glyph       = '🦅'
persona     = SPARK[/RUNTIME SPEC :: .*?\n"(.*?)"/m, 1] ||
              'Personal sidekick agent — triages intent and routes to sub-agents.'
tg          = ROUTES['telegram']     || {}
mesh        = ROUTES['mesh']         || {}

speaker_fragment = {
  'agent'      => agent,
  'slot'       => slot,
  'glyph'      => glyph,
  'persona'    => persona,
  'system'     => "You are #{agent}, Lucius's daily-driver sidekick. " \
                  "You are calm, terse, action-first. You triage intent " \
                  "and route requests to the right sub-agent (Money.Bagz " \
                  "for bills/budget, VSO.Agent for VA/disability), " \
                  "otherwise you handle notes/plans/status yourself.",
  'inference'  => {
    'serving'      => 'single_slot',
    'hydrate_from' => %w[slot.receipt_tail slot.status_snapshot slot.runtime_log_slice]
  },
  'mesh'       => mesh,
  'updated_at' => Time.now.utc.iso8601
}

route_fragment = {
  'agent'    => agent,
  'slot'     => slot,
  'telegram' => {
    'chat_id'           => tg['chat_id'],
    'allowed_chat_ids'  => tg['allowed_chat_ids'] || [],
    'allowed_topics'    => tg['allowed_topics']   || []
  },
  'topics' => (ROUTES['intent_to_subagent'] || {}).map { |intent, target|
    {
      'intent'    => intent,
      'route_to'  => target,
      'subagent'  => (ROUTES.dig('subagents', target) || {})['path']
    }
  },
  'updated_at' => Time.now.utc.iso8601
}

receipt = {
  'kind'        => 'tpr.fragment.emitted',
  'agent'       => agent,
  'slot'        => slot,
  'speaker_path' => SPEAKER.sub(ROOT + '/', ''),
  'route_path'  => ROUTE_MAP.sub(ROOT + '/', ''),
  'created_at'  => Time.now.utc.iso8601
}

File.write(SPEAKER,   JSON.pretty_generate(speaker_fragment))
File.write(ROUTE_MAP, JSON.pretty_generate(route_fragment))
File.write(RECEIPT,   JSON.pretty_generate(receipt))

puts JSON.pretty_generate({
  'agent'   => agent,
  'wrote'   => [SPEAKER, ROUTE_MAP, RECEIPT].map { |p| p.sub(ROOT + '/', '') },
  'merge_target' => 'TelePromptR/<TPR_ZENS3N>/merge.sh',
  'next'    => 'rsync to VPS, then `cd $TPR_DIR && TPR_ZENS3N=$TPR_REPO bash merge.sh`'
})
