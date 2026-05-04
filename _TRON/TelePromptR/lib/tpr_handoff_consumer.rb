#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# TPR handoff consumer — walks registered agent handoff dirs, validates,
# fans into TPR topic queues, writes acks + rejects + expires.
#
# Designed to be idempotent and side-effect-only via filesystem moves.
# No Telegram I/O here — that stays in TelePromptR's existing speaker.

require 'json'
require 'time'
require 'fileutils'
require 'digest'

require_relative 'tpr_handoff_schema'

module TPR
  class HandoffConsumer
    DEFAULTS = {
      stale_after_hours: 72,
      runtime_root: nil,        # e.g. /root/!CMD.VPS/TelePromptR/var
      route_map_path: nil       # e.g. /root/!CMD.VPS/TelePromptR/route.map.json
    }.freeze

    Outcome = Struct.new(:scanned, :acked, :rejected, :expired, :skipped, :errors, keyword_init: true) do
      def to_h
        members.each_with_object({}) { |m, h| h[m.to_s] = self[m] }
      end
    end

    def initialize(agents:, runtime_root:, route_map_path: nil, stale_after_hours: 72, clock: Time.method(:now))
      @agents            = agents.is_a?(Array) ? agents : [agents].compact
      @runtime_root      = runtime_root
      @route_map_path    = route_map_path
      @stale_after_hours = stale_after_hours
      @clock             = clock
      @route_map         = load_route_map(route_map_path)
      @queue_dir         = File.join(@runtime_root, 'queue')
      FileUtils.mkdir_p(@queue_dir)
    end

    def run
      outcome = Outcome.new(scanned: 0, acked: 0, rejected: 0, expired: 0, skipped: 0, errors: [])

      @agents.each do |agent|
        handoff_dir = agent[:handoff_dir]
        next unless File.directory?(handoff_dir)

        ack_dir      = File.join(handoff_dir, '.acks')
        reject_dir   = File.join(handoff_dir, '.rejected')
        expired_dir  = File.join(handoff_dir, '.expired')
        processed_dir = File.join(handoff_dir, '.processed')
        [ack_dir, reject_dir, expired_dir, processed_dir].each { |d| FileUtils.mkdir_p(d) }

        Dir.glob(File.join(handoff_dir, '*.handoff.json')).sort.each do |path|
          outcome.scanned += 1
          id_guess = File.basename(path, '.handoff.json')

          text = File.read(path)
          result = TPR::HandoffSchema.validate_text(text)

          if result.fail?
            # Reject id is best-effort: prefer the parsed id, otherwise filename stem.
            reject_id = (result.record.is_a?(Hash) && result.record['id']) || id_guess
            if File.exist?(File.join(reject_dir, "#{reject_id}.error.json"))
              FileUtils.mv(path, reject_dir) if File.exist?(path)
              outcome.skipped += 1
              next
            end
            error_record = {
              'id' => reject_id,
              'kind' => 'tpr.handoff.rejected',
              'errors' => result.errors,
              'warnings' => result.warnings,
              'rejected_at' => @clock.call.utc.iso8601,
              'source_path' => path
            }
            File.write(File.join(reject_dir, "#{reject_id}.error.json"), JSON.pretty_generate(error_record))
            FileUtils.mv(path, reject_dir)
            outcome.rejected += 1
            next
          end

          rec = result.record

          # Idempotent short-circuit on inner id.
          if File.exist?(File.join(ack_dir, "#{rec['id']}.ack.json"))
            FileUtils.mv(path, processed_dir) if File.exist?(path)
            outcome.skipped += 1
            next
          end

          if stale?(rec)
            FileUtils.mv(path, expired_dir)
            outcome.expired += 1
            next
          end

          topic = resolve_topic(rec)
          enqueue(topic, rec)

          ack = {
            'id' => rec['id'],
            'kind' => 'tpr.handoff.ack',
            'in_reply_to' => rec['in_reply_to'],
            'from_agent' => rec['from_agent'],
            'to_agent' => rec['to_agent'],
            'topic' => topic,
            'queue_path' => queue_path(topic),
            'warnings' => result.warnings,
            'acked_at' => @clock.call.utc.iso8601,
            'source_sha256' => Digest::SHA256.hexdigest(text)
          }
          File.write(File.join(ack_dir, "#{rec['id']}.ack.json"), JSON.pretty_generate(ack))
          FileUtils.mv(path, processed_dir)
          outcome.acked += 1
        rescue => e
          outcome.errors << { 'path' => path, 'error' => "#{e.class}: #{e.message}" }
        end
      end

      outcome
    end

    private

    def stale?(rec)
      return false unless rec['created_at']
      created = Time.iso8601(rec['created_at'])
      (@clock.call - created) > (@stale_after_hours * 3600)
    rescue ArgumentError
      false
    end

    def resolve_topic(rec)
      to    = rec['to_agent']
      hint  = (rec['topics_hint'] || []).first
      mapped = @route_map.dig('to_agent', to)
      mapped ||= @route_map.dig('classified_key', rec['classified_key']) if rec['classified_key']
      mapped || hint || to
    end

    def enqueue(topic, rec)
      File.open(queue_path(topic), 'a') do |f|
        f.puts(JSON.generate({
          'kind' => 'topic.enqueue',
          'topic' => topic,
          'handoff_id' => rec['id'],
          'from_agent' => rec['from_agent'],
          'to_agent' => rec['to_agent'],
          'subagent_path' => rec['subagent_path'],
          'text' => rec['text'],
          'enqueued_at' => @clock.call.utc.iso8601
        }))
      end
    end

    def queue_path(topic)
      safe = topic.to_s.gsub(/[^A-Za-z0-9._-]/, '_')
      File.join(@queue_dir, "#{safe}.jsonl")
    end

    def load_route_map(path)
      return {} unless path && File.file?(path)
      JSON.parse(File.read(path))
    rescue JSON::ParserError
      {}
    end
  end
end
