#!/usr/bin/env ruby
#
# GENERATE_KEY.RB :: 3OX License Key Generator
# Purpose: Create signed, machine-bound activation keys
#

require 'digest'
require 'date'

def get_machine_id
  hostname = `hostname`.strip
  username = ENV['USERNAME'] || ENV['USER'] || 'unknown'
  os_info = `ver`.strip rescue RUBY_PLATFORM
  
  machine_string = "#{hostname}|#{username}|#{os_info}"
  Digest::SHA256.hexdigest(machine_string)[0..15]
end

def generate_signature(key_content)
  # Sign with secret salt (in production, use private key)
  Digest::SHA256.hexdigest(key_content + "3OX_SECRET_SALT")[0..31]
end

def create_key(options = {})
  # Defaults
  name = options[:name] || "GUARDIAN"
  licensed_to = options[:licensed_to] || "Customer"
  expires = options[:expires] || "NEVER"
  machine_bind = options[:machine_bind] != false  # Default true
  
  # Get machine ID if binding
  machine_id = machine_bind ? get_machine_id : nil
  
  # Build key content
  key_content = <<~KEY
  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂| 3OX ACTIVATION KEY v1.1.0 |▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
  ▛//▞▞ ⟦⎊⟧ :: ⧗-25.291 // 3OX.KEY :: ACTIVATION.CORE ▸ 
  //▞ COMMERCIAL LICENSE :: ρ{Unlock}.τ{Configure}.ν{Authorize}.λ{Bind} ⫸
  
  ▛▞ LICENSE ::
  status: ACTIVATED
  version: v1.1.0
  license_type: COMMERCIAL
  licensed_to: #{licensed_to}
  activation_date: #{Date.today}
  expires: #{expires}
  runtime: ruby
  :: ∎
  
  ▛▞ MACHINE BINDING ::
  enabled: #{machine_bind}
  machine_id: #{machine_id || 'NONE'}
  transfer_policy: CONTACT_VENDOR
  :: ∎
  
  ▛▞ FRAMEWORK UNLOCK ::
  enabled: true
  workspace_access: FULL
  tool_registry: UNLOCKED
  routing_enabled: true
  limits_enforced: true
  receipt_generation: ACTIVE
  brain_mode: COMPILED (brain.exe)
  :: ∎
  
  ▛▞ IDENTITY ::
  name: #{name}
  type: Sentinel (Guardian-Synchronizer)
  model: claude-sonnet-4.5
  sigil: 〘⟦⎊⟧・.°RUBY.RB〙
  rules: AtomicOpsOnly, AlwaysBackup, ChecksumValidation
  :: ∎
  
  ▛▞ AUTHORIZED OPERATIONS ::
  file_validation: ENABLED
  receipt_generation: ENABLED
  routing_handoffs: ENABLED
  batch_operations: ENABLED
  hash_verification: xxHash64
  offline_capable: YES
  :: ∎
  
  KEY
  
  # Generate signature
  signature = generate_signature(key_content)
  
  # Append signature
  key_content += "▛▞ SECURITY ::\n"
  key_content += "signature: #{signature}\n"
  key_content += "algorithm: SHA256+SALT\n"
  key_content += ":: ∎\n\n"
  key_content += "///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂| AUTHORIZED COPY | ⧗-25.291 |▂▂▂▂▂▂▂▂▂▂▂▂///\n"
  
  key_content
end

# ============================================================================
# CLI Interface
# ============================================================================

if __FILE__ == $0
  puts "3OX LICENSE KEY GENERATOR"
  puts "=" * 60
  puts ""
  
  if ARGV[0] == "machine_id"
    puts "Current Machine ID: #{get_machine_id}"
    puts ""
    puts "Use this ID when generating keys for this machine."
    exit 0
  end
  
  # Parse options
  options = {}
  options[:name] = ARGV.find { |a| a.start_with?("--name=") }&.split("=", 2)&.last
  options[:licensed_to] = ARGV.find { |a| a.start_with?("--to=") }&.split("=", 2)&.last
  options[:expires] = ARGV.find { |a| a.start_with?("--expires=") }&.split("=", 2)&.last
  options[:machine_bind] = !ARGV.include?("--no-bind")
  
  # Generate key
  key_content = create_key(options)
  
  # Write to file
  File.write("3ox.key", key_content)
  
  puts "✓ Key generated: 3ox.key"
  puts "✓ Machine ID: #{get_machine_id}" if options[:machine_bind]
  puts "✓ Licensed to: #{options[:licensed_to] || 'Customer'}"
  puts "✓ Expires: #{options[:expires] || 'NEVER'}"
  puts ""
  puts "Usage: ruby run.rb [operations...]"
  puts "=" * 60
end

