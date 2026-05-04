#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# Tests for TPR::HandoffSchema (stdlib minitest, no gems).

require 'minitest/autorun'
require 'json'
require 'pathname'

LIB = Pathname.new(__dir__).join('..', 'lib').realpath.to_s
$LOAD_PATH.unshift(LIB)
require 'tpr_handoff_schema'

FIXTURES = Pathname.new(__dir__).join('..', 'fixtures', 'handoff').realpath

class HandoffSchemaTest < Minitest::Test
  def fixture(name)
    FIXTURES.join(name).read
  end

  def test_valid_money_bagz_handoff
    r = TPR::HandoffSchema.validate_text(fixture('valid_sidekik_money_bagz.handoff.json'))
    assert r.ok?, "expected ok, got errors=#{r.errors.inspect}"
    assert_empty r.errors
  end

  def test_valid_vso_agent_handoff
    r = TPR::HandoffSchema.validate_text(fixture('valid_sidekik_vso_agent.handoff.json'))
    assert r.ok?
    assert_empty r.errors
  end

  def test_missing_required_field_text
    r = TPR::HandoffSchema.validate_text(fixture('invalid_missing_text.handoff.json'))
    refute r.ok?
    assert_includes r.errors.join("\n"), 'missing required field "text"'
  end

  def test_wrong_kind_rejected
    r = TPR::HandoffSchema.validate_text(fixture('invalid_wrong_kind.handoff.json'))
    refute r.ok?
    assert_includes r.errors.join("\n"), 'kind must be'
  end

  def test_unknown_field_warns_but_ok
    rec = JSON.parse(fixture('valid_sidekik_money_bagz.handoff.json'))
    rec['mystery_field'] = 'whatever'
    r = TPR::HandoffSchema.validate(rec)
    assert r.ok?, "expected ok with warnings, got errors=#{r.errors.inspect}"
    assert(r.warnings.any? { |w| w.include?('mystery_field') })
  end

  def test_bad_json_rejected
    r = TPR::HandoffSchema.validate_text('not json')
    refute r.ok?
    assert_includes r.errors.first, 'json parse'
  end

  def test_topics_hint_must_be_strings
    rec = JSON.parse(fixture('valid_sidekik_money_bagz.handoff.json'))
    rec['topics_hint'] = ['ok', 42]
    r = TPR::HandoffSchema.validate(rec)
    refute r.ok?
    assert_includes r.errors.join("\n"), 'topics_hint'
  end

  def test_bad_created_at_rejected
    rec = JSON.parse(fixture('valid_sidekik_money_bagz.handoff.json'))
    rec['created_at'] = 'last tuesday'
    r = TPR::HandoffSchema.validate(rec)
    refute r.ok?
    assert_includes r.errors.join("\n"), 'created_at'
  end
end
