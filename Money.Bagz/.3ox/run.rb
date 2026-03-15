#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.03.13]
# doc:[PARTIAL] modified:[26.03.13] auth:[3OX.AI]
# Money.Bagz entry — delegates to .vec3/rc/run.rb or (6)Pulse

rc = File.join(__dir__, '.vec3', 'rc', 'run.rb')
pulse = File.join(__dir__, '(6)Pulse', 'run.rb')
load File.exist?(rc) ? rc : pulse
