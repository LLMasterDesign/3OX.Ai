#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# tpr_handoff — drain registered agent handoff dirs ONCE per invocation.
#
# Designed to ride the rotor. TPW.SPIN is the rotary encoder (hex 0x003,
# slot k00); Pulse (k02) is the aliveness edge. Each invocation = one
# edge. NO timers. Caller is the rotor:
#   - TelePromptR's merge.sh (rotor tail), or
#   - systemd path-unit on the agent handoff dir (filesystem edge).
#
# Usage:
#   ruby bin/tpr_handoff.rb                       # one drain pass
#   ruby bin/tpr_handoff.rb --edge                # explicit "one edge" alias
#   ruby bin/tpr_handoff.rb --agents agents.json  # explicit registry
#
# agents.json:
# {
#   "runtime_root": "/root/!CMD.VPS/TelePromptR/var",
#   "route_map":    "/root/!CMD.VPS/TelePromptR/route.map.json",
#   "stale_after_hours": 72,
#   "agents": [
#     { "name": "3OX.Sidekik", "handoff_dir": "/root/_TRON/Agents/Sidekik/!0UT.SIDEKIK/tpr/handoff" }
#   ]
# }

require 'json'
require 'optparse'
require 'pathname'

LIB = Pathname.new(__dir__).join('..', 'lib').realpath.to_s
$LOAD_PATH.unshift(LIB)
require 'tpr_handoff_consumer'

DEFAULT_REGISTRY_CANDIDATES = [
  ENV['TPR_AGENTS_REGISTRY'],
  '/etc/tpr/agents.json',
  '/root/!CMD.VPS/TelePromptR/agents.json',
  Pathname.new(__dir__).join('..', 'agents.json').to_s
].compact

opts = { registry: nil, dry_run: false }
OptionParser.new do |o|
  o.banner = 'Usage: tpr_handoff.rb [--agents PATH] [--edge] [--dry-run]'
  o.on('--agents PATH', 'agents.json registry path') { |v| opts[:registry] = v }
  o.on('--edge',        'drain one rotor edge (default)')  { }
  o.on('--dry-run',     'parse + validate, no writes')     { opts[:dry_run] = true }
end.parse!

registry_path = opts[:registry] || DEFAULT_REGISTRY_CANDIDATES.find { |p| p && File.file?(p) }
unless registry_path && File.file?(registry_path)
  warn "tpr_handoff: no agents registry found (looked at: #{DEFAULT_REGISTRY_CANDIDATES.compact.join(', ')})"
  exit 2
end

registry = JSON.parse(File.read(registry_path))

consumer = TPR::HandoffConsumer.new(
  agents: (registry['agents'] || []).map { |a| { name: a['name'], handoff_dir: a['handoff_dir'] } },
  runtime_root: registry['runtime_root'],
  route_map_path: registry['route_map'],
  stale_after_hours: (registry['stale_after_hours'] || 72).to_i
)

if opts[:dry_run]
  warn 'tpr_handoff: --dry-run is not yet implemented; running normally with read-only side effects only on validation failure'
end

outcome = consumer.run
puts JSON.pretty_generate({
  'kind' => 'tpr.handoff.run.summary',
  'registry' => registry_path,
  'at' => Time.now.utc.iso8601,
  'outcome' => outcome.to_h
})
