# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.202 // WORKBOOK :: storm_proof_test ▞▞

defmodule GlyphBit.StormProofTest do
  use ExUnit.Case, async: false

  @moduletag :proof

  setup do
    GlyphBit.Tape.reset_for_test()
    GlyphBit.reset_turn()
    :ok
  end

  test "P1 fire — delay keywords → post.emit context blurb" do
    result = GlyphBit.after_chat(GlyphBit.Fixtures.p1_fire())
    assert result.tau == :post_emit
    assert result.tau_wire == "post.emit"
    assert is_binary(result.blurb)
    assert result.blurb == result.line
    assert String.contains?(result.blurb, "Γ STORM")
    assert String.contains?(result.blurb, "HRÆSVELGR")
    # deity blurb — more than a slogan line
    assert length(String.split(result.blurb, "\n")) >= 3
    assert String.length(result.blurb) > 120
    assert result.rate.verdict == :fire
  end

  test "P2 hold — clean ack → abstain.silence" do
    result = GlyphBit.after_chat(GlyphBit.Fixtures.p2_hold_clean())
    assert result.tau == :abstain_silence
    assert result.line == nil
    assert result.rate.verdict == :hold
  end

  test "P3 hold — no primary → silence" do
    result = GlyphBit.after_chat(GlyphBit.Fixtures.p3_no_primary())
    assert result.tau == :abstain_silence
    assert result.line == nil
    assert Enum.any?(result.rate.reasons, &String.contains?(&1, "no_primary"))
  end

  test "P4 uniqueness — second post same turn → silence" do
    r1 = GlyphBit.after_chat(GlyphBit.Fixtures.p1_fire())
    assert r1.tau == :post_emit

    r2 = GlyphBit.after_chat(GlyphBit.Fixtures.p1_fire())
    assert r2.tau == :abstain_silence
    assert r2.line == nil
  end

  test "P5 ambiguous → fail-closed silence" do
    result = GlyphBit.after_chat(GlyphBit.Fixtures.p5_ambiguous())
    assert result.tau == :abstain_silence
    assert result.line == nil
  end

  test "P6 aliveness — restart recovers identity; same ctx → same τ class" do
    r1 = GlyphBit.after_chat(GlyphBit.Fixtures.p1_fire())
    assert r1.tau == :post_emit

    beat1 = GlyphBit.heartbeat()
    assert beat1.alive
    assert beat1.glyphbit_id == "Storm"
    assert beat1.primary == false

    # Crash and let supervisor restart
    ref = Process.monitor(Process.whereis(GlyphBit.Storm))
    Process.exit(Process.whereis(GlyphBit.Storm), :kill)
    assert_receive {:DOWN, ^ref, :process, _, _}, 500

    # Wait for restart
    :ok = wait_storm(20)
    beat2 = GlyphBit.heartbeat()
    assert beat2.alive
    assert beat2.glyphbit_id == "Storm"
    assert beat2.ontology_claim == GlyphBit.Ontology.claim()

    r2 = GlyphBit.after_chat(GlyphBit.Fixtures.p1_fire())
    assert r2.tau == :post_emit
  end

  test "P7 boundary fail-closed → silence" do
    result = GlyphBit.after_chat(GlyphBit.Fixtures.p7_boundary())
    assert result.tau == :abstain_silence
    assert result.line == nil
  end

  test "tape records fire and silence" do
    GlyphBit.after_chat(GlyphBit.Fixtures.p1_fire())
    GlyphBit.reset_turn()
    GlyphBit.after_chat(GlyphBit.Fixtures.p2_hold_clean())

    entries = GlyphBit.Tape.entries()
    assert length(entries) >= 2
    taus = Enum.map(entries, & &1[:tau])
    assert "post.emit" in taus
    assert "abstain.silence" in taus
  end

  test "compiler validates spark and writes blake3 digest" do
    {:ok, artifact} = GlyphBit.Compiler.run!()
    assert artifact.ontology.uniqueness.primary == false
    assert artifact.hash_algo == "blake3"
    assert artifact.blake3 != ""
    assert String.length(artifact.blake3) == 64
    assert File.exists?("compile/storm.blake3")
    refute File.exists?("compile/storm.sha256")
    assert File.exists?("compile/storm.glyphbit.artifact.exs")
  end

  test "internal hash is blake3" do
    assert GlyphBit.Hash.algo_internal() == :blake3
    digest = GlyphBit.Hash.internal("glyphbit-storm")
    assert String.length(digest) == 64
    # stable
    assert digest == GlyphBit.Hash.internal("glyphbit-storm")
  end

  test "ontology rejects illegal tau" do
    assert_raise ArgumentError, fn ->
      GlyphBit.Ontology.assert_tau!(:primary_reply)
    end
  end

  defp wait_storm(0), do: flunk("Storm GenServer did not restart")

  defp wait_storm(n) do
    case Process.whereis(GlyphBit.Storm) do
      nil ->
        Process.sleep(25)
        wait_storm(n - 1)

      pid when is_pid(pid) ->
        # give init a moment
        Process.sleep(20)
        :ok
    end
  end
end
