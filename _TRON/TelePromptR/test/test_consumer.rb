#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.05.04]
# doc:[COMPLETE] modified:[26.05.04] auth:[ZEN.PRO]
# Tests for TPR::HandoffConsumer (stdlib minitest, no gems).

require 'minitest/autorun'
require 'tmpdir'
require 'json'
require 'fileutils'
require 'pathname'
require 'time'

LIB = Pathname.new(__dir__).join('..', 'lib').realpath.to_s
$LOAD_PATH.unshift(LIB)
require 'tpr_handoff_consumer'

FIXTURES = Pathname.new(__dir__).join('..', 'fixtures', 'handoff').realpath

class HandoffConsumerTest < Minitest::Test
  def setup
    @tmp = Dir.mktmpdir('tpr_handoff_test_')
    @handoff_dir = File.join(@tmp, 'agent', '!0UT.SIDEKIK', 'tpr', 'handoff')
    FileUtils.mkdir_p(@handoff_dir)
    @runtime = File.join(@tmp, 'tpr', 'var')
    FileUtils.mkdir_p(@runtime)
  end

  def teardown
    FileUtils.remove_entry(@tmp) if @tmp && File.directory?(@tmp)
  end

  def copy_fixture(name, dest_name = nil)
    src = FIXTURES.join(name).to_s
    dest = File.join(@handoff_dir, dest_name || name)
    FileUtils.cp(src, dest)
    dest
  end

  def consumer(stale: 72, clock: Time.method(:now), route_map_path: nil)
    TPR::HandoffConsumer.new(
      agents: [{ name: '3OX.Sidekik', handoff_dir: @handoff_dir }],
      runtime_root: @runtime,
      route_map_path: route_map_path,
      stale_after_hours: stale,
      clock: clock
    )
  end

  def test_acks_valid_and_enqueues_topic
    copy_fixture('valid_sidekik_money_bagz.handoff.json')
    out = consumer.run

    assert_equal 1, out.scanned
    assert_equal 1, out.acked
    assert_equal 0, out.rejected

    queue_files = Dir.glob(File.join(@runtime, 'queue', '*.jsonl'))
    assert_equal 1, queue_files.size
    line = File.read(queue_files.first).each_line.first
    enq = JSON.parse(line)
    assert_equal 'topic.enqueue', enq['kind']
    assert_equal 'money_bagz', enq['to_agent']
    assert_equal 'pay the electric bill', enq['text']

    ack_files = Dir.glob(File.join(@handoff_dir, '.acks', '*.ack.json'))
    assert_equal 1, ack_files.size
    ack = JSON.parse(File.read(ack_files.first))
    assert_equal 'tpr.handoff.ack', ack['kind']
    assert_equal 'sk.h.20260504T080926-fixt1', ack['id']
    assert_match(/^[a-f0-9]{64}$/, ack['source_sha256'])

    assert_empty Dir.glob(File.join(@handoff_dir, '*.handoff.json'))
    assert_equal 1, Dir.glob(File.join(@handoff_dir, '.processed', '*.handoff.json')).size
  end

  def test_rejects_invalid_kind
    copy_fixture('invalid_wrong_kind.handoff.json')
    out = consumer.run

    assert_equal 1, out.rejected
    assert_equal 0, out.acked
    rejects = Dir.glob(File.join(@handoff_dir, '.rejected', '*.error.json'))
    assert_equal 1, rejects.size
    err = JSON.parse(File.read(rejects.first))
    assert_equal 'tpr.handoff.rejected', err['kind']
    refute_empty err['errors']
  end

  def test_expires_stale_records
    path = copy_fixture('valid_sidekik_money_bagz.handoff.json', 'stale.handoff.json')
    rec = JSON.parse(File.read(path))
    rec['created_at'] = (Time.now - (200 * 3600)).utc.iso8601 # 200 hours ago
    File.write(path, JSON.pretty_generate(rec))

    out = consumer.run
    assert_equal 1, out.expired
    assert_equal 0, out.acked
    assert_equal 1, Dir.glob(File.join(@handoff_dir, '.expired', '*.handoff.json')).size
  end

  def test_idempotent_skip_after_ack
    copy_fixture('valid_sidekik_money_bagz.handoff.json')
    out1 = consumer.run
    assert_equal 1, out1.acked

    # Drop the *same* handoff back into the dir.
    copy_fixture('valid_sidekik_money_bagz.handoff.json')
    out2 = consumer.run
    assert_equal 1, out2.skipped
    assert_equal 0, out2.acked

    # Queue should still hold exactly one enqueue line — no duplicate.
    queue_files = Dir.glob(File.join(@runtime, 'queue', '*.jsonl'))
    line_count = File.foreach(queue_files.first).count
    assert_equal 1, line_count
  end

  def test_route_map_overrides_to_agent
    map_path = File.join(@tmp, 'route.map.json')
    File.write(map_path, JSON.dump({ 'to_agent' => { 'money_bagz' => 'finance.bills' } }))
    copy_fixture('valid_sidekik_money_bagz.handoff.json')

    out = consumer(route_map_path: map_path).run
    assert_equal 1, out.acked

    queue_files = Dir.glob(File.join(@runtime, 'queue', '*.jsonl'))
    assert_equal 1, queue_files.size
    assert_equal 'finance.bills.jsonl', File.basename(queue_files.first)
  end
end
