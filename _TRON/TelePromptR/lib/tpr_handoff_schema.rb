#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# tpr.handoff schema validator (no external gems; stdlib only).

require 'json'
require 'time'

module TPR
  module HandoffSchema
    VERSION         = '1'
    REQUIRED_FIELDS = %w[kind id from_agent to_agent subagent_path text created_at].freeze
    OPTIONAL_FIELDS = %w[schema_version in_reply_to topics_hint classified_key consumer merge_via speaker_unit].freeze
    KNOWN_FIELDS    = (REQUIRED_FIELDS + OPTIONAL_FIELDS).freeze
    KIND            = 'tpr.handoff'

    Result = Struct.new(:ok, :errors, :warnings, :record, keyword_init: true) do
      def ok?      = ok
      def fail?    = !ok
      def to_h     = { ok: ok, errors: errors, warnings: warnings }
      def to_json(*a) = to_h.to_json(*a)
    end

    module_function

    def validate_text(text)
      data = JSON.parse(text)
    rescue JSON::ParserError => e
      return Result.new(ok: false, errors: ["json parse: #{e.message}"], warnings: [], record: nil)
    else
      validate(data)
    end

    def validate(data)
      errors   = []
      warnings = []

      unless data.is_a?(Hash)
        return Result.new(ok: false, errors: ['handoff must be a JSON object'], warnings: [], record: nil)
      end

      if data['kind'] != KIND
        errors << "kind must be #{KIND.inspect}, got #{data['kind'].inspect}"
      end

      REQUIRED_FIELDS.each do |f|
        v = data[f]
        if v.nil? || (v.is_a?(String) && v.strip.empty?)
          errors << "missing required field #{f.inspect}"
        end
      end

      if (sv = data['schema_version']) && sv != VERSION
        warnings << "unknown schema_version #{sv.inspect}; consumer is v#{VERSION}"
      end

      if (ts = data['created_at'])
        begin
          Time.iso8601(ts)
        rescue ArgumentError
          errors << "created_at #{ts.inspect} is not RFC3339"
        end
      end

      if (th = data['topics_hint'])
        unless th.is_a?(Array) && th.all? { |t| t.is_a?(String) }
          errors << 'topics_hint must be array of strings'
        end
      end

      unknown = data.keys - KNOWN_FIELDS
      warnings += unknown.map { |k| "unknown field #{k.inspect}" }

      Result.new(ok: errors.empty?, errors: errors, warnings: warnings, record: data)
    end
  end
end
