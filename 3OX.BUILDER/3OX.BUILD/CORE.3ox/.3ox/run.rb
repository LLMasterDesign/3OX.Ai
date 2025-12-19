#!/usr/bin/env ruby
#
# RUN.RB :: .3OX Runtime for Sysadmin
# Minimal test implementation
#

require 'xxhash'
require 'time'
require 'fileutils'
require 'json'
require 'yaml'
require 'openssl'
require 'digest'

# ============================================================================
# Activation Key Check
# ============================================================================

def get_machine_id
  # Generate stable machine ID from hardware/OS info
  hostname = `hostname`.strip
  username = ENV['USERNAME'] || ENV['USER'] || 'unknown'
  os_info = `ver`.strip rescue RUBY_PLATFORM
  
  # Combine and hash for machine fingerprint
  machine_string = "#{hostname}|#{username}|#{os_info}"
  Digest::SHA256.hexdigest(machine_string)[0..15]
end

def parse_key_content(content)
  key_data = {}
  
  key_data[:status] = content[/status: ([^\n]+)/, 1]
  key_data[:version] = content[/version: ([^\n]+)/, 1]
  key_data[:name] = content[/name: ([^\n]+)/, 1]
  key_data[:runtime] = content[/runtime: ([^\n]+)/, 1]
  key_data[:expires] = content[/expires: ([^\n]+)/, 1]
  key_data[:machine_id] = content[/machine_id: ([^\n]+)/, 1]
  key_data[:signature] = content[/signature: ([^\n]+)/, 1]
  
  key_data
end

def verify_key_signature(content, signature)
  # Extract payload (everything before SECURITY section)
  payload = content.split(/▛▞ SECURITY ::/)[0]
  
  # Compute expected signature
  expected = Digest::SHA256.hexdigest(payload + "3OX_SECRET_SALT")[0..31]
  
  signature == expected
end

def check_activation_key
  # Try multiple key file names
  key_files = ["3ox.key"]
  key_file = nil
  
  key_files.each do |filename|
    path = File.join(File.dirname(__FILE__), filename)
    if File.exist?(path)
      key_file = path
      break
    end
  end
  
  # Check 1: Key file exists
  unless key_file
    puts "❌ ACTIVATION KEY MISSING"
    puts "━" * 60
    puts "This workspace requires an activation key to operate."
    puts "Expected file: 3ox.key"
    puts "Location: #{File.dirname(__FILE__)}"
    puts "━" * 60
    puts "Status: LOCKED"
    puts ""
    puts "To purchase a license key:"
    puts "Contact: license@3ox.ai"
    exit 1
  end
  
  content = File.read(key_file)
  key_data = parse_key_content(content)
  
  # Check 2: Activation status
  unless key_data[:status] == "ACTIVATED"
    puts "❌ ACTIVATION KEY INVALID"
    puts "━" * 60
    puts "Activation key found but not activated."
    puts "Status: #{key_data[:status] || 'UNKNOWN'}"
    puts "━" * 60
    puts "Status: LOCKED"
    exit 1
  end
  
  # Check 3: Expiration date
  if key_data[:expires] && key_data[:expires] != "NEVER"
    expiration = Date.parse(key_data[:expires]) rescue nil
    if expiration && Date.today > expiration
      puts "❌ LICENSE EXPIRED"
      puts "━" * 60
      puts "Your license expired on: #{key_data[:expires]}"
      puts "Please renew your license."
      puts "━" * 60
      puts "Status: LOCKED"
      exit 1
    end
  end
  
  # Check 4: Machine binding
  if key_data[:machine_id]
    current_machine = get_machine_id
    unless key_data[:machine_id] == current_machine
      puts "❌ MACHINE ID MISMATCH"
      puts "━" * 60
      puts "This key is locked to a different machine."
      puts "Expected: #{key_data[:machine_id]}"
      puts "Current:  #{current_machine}"
      puts "━" * 60
      puts "Status: LOCKED"
      puts ""
      puts "To transfer license:"
      puts "Contact: license@3ox.ai"
      exit 1
    end
  end
  
  # Check 5: Cryptographic signature
  if key_data[:signature]
    unless verify_key_signature(content, key_data[:signature])
      puts "❌ KEY SIGNATURE INVALID"
      puts "━" * 60
      puts "This key has been tampered with or is counterfeit."
      puts "━" * 60
      puts "Status: LOCKED"
      exit 1
    end
  end
  
  puts "🔓 ACTIVATION KEY VERIFIED"
  puts "━" * 60
  puts "Agent: #{key_data[:name]}"
  puts "Runtime: #{key_data[:runtime]}"
  puts "Status: UNLOCKED"
  puts "Machine: #{get_machine_id}"
  if key_data[:expires] && key_data[:expires] != "NEVER"
    puts "Expires: #{key_data[:expires]}"
  end
  puts "━" * 60
  puts ""
end

# ============================================================================
# Core Functions
# ============================================================================

def validate_file(filepath)
  unless File.exist?(filepath)
    return { valid: false, error: "File not found" }
  end
  
  file_hash = XXhash.xxh64(File.read(filepath)).to_s(16)
  
  {
    valid: true,
    path: filepath,
    hash: file_hash[0..15],
    size: File.size(filepath)
  }
end

def load_tools
  tools_file = File.join(File.dirname(__FILE__), "tools.yml")
  return {} unless File.exist?(tools_file)
  
  YAML.load_file(tools_file)
end

def load_routes
  routes_file = File.join(File.dirname(__FILE__), "routes.json")
  return {} unless File.exist?(routes_file)
  
  JSON.parse(File.read(routes_file))["routes"]
end

def load_limits
  limits_file = File.join(File.dirname(__FILE__), "limits.json")
  return {} unless File.exist?(limits_file)
  
  JSON.parse(File.read(limits_file))
end

def load_brain
  brain_bin = File.join(File.dirname(__FILE__), "brain.exe")
  
  # Try to run compiled Rust binary
  if File.exist?(brain_bin)
    output = `#{brain_bin} config 2>&1`
    return JSON.parse(output) if $?.success?
  end
  
  # Fallback: Parse brain.rs as text
  brain_file = File.join(File.dirname(__FILE__), "brain.rs")
  return { "name" => "UNKNOWN", "type" => "Sentinel", "rules" => [] } unless File.exist?(brain_file)
  
  content = File.read(brain_file)
  name = content[/name: "([^"]+)"/, 1] || "GUARDIAN"
  brain_type = content[/brain: BrainType::(\w+)/, 1] || "Sentinel"
  rules = content.scan(/Rule::(\w+)/).flatten.uniq
  
  { "name" => name, "type" => brain_type, "rules" => rules }
end

def check_file_limits(filepath)
  limits = load_limits
  max_size_mb = limits.dig("resources", "files", "max_file_size_mb") || 100
  max_size_bytes = max_size_mb * 1024 * 1024
  
  file_size = File.size(filepath)
  
  if file_size > max_size_bytes
    return {
      within_limits: false,
      reason: "File size #{file_size} bytes exceeds limit of #{max_size_bytes} bytes",
      file_size_mb: (file_size / 1024.0 / 1024.0).round(2),
      limit_mb: max_size_mb
    }
  end
  
  {
    within_limits: true,
    file_size_mb: (file_size / 1024.0 / 1024.0).round(2),
    limit_mb: max_size_mb
  }
end

def log_operation(operation, status, details = "")
  log_file = File.join(File.dirname(__FILE__), "3ox.log")
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  sigil = "〘⟦⎊⟧・.°RUBY.RB〙"
  
  log_entry = "\n[#{timestamp}] #{sigil}\n"
  log_entry += "  Operation: #{operation}\n"
  log_entry += "  Status: #{status}\n"
  log_entry += "  Details: #{details}\n" unless details.empty?
  
  File.open(log_file, "a") { |f| f.write(log_entry) }
end

def route_output(operation, receipt)
  routes = load_routes
  destination = routes[operation] || "0ut.3ox"
  
  # Create destination directory
  FileUtils.mkdir_p(destination)
  
  # Write receipt to destination
  receipt_file = File.join(destination, "receipt_#{Time.now.strftime('%Y%m%d_%H%M%S')}.log")
  File.open(receipt_file, "w") do |f|
    f.puts "Operation: #{receipt[:operation]}"
    f.puts "File: #{receipt[:file]}"
    f.puts "Hash: #{receipt[:hash]}"
    f.puts "Time: #{receipt[:timestamp]}"
    f.puts "Routed to: #{destination}"
  end
  
  destination
end

def generate_receipt(filepath, operation)
  result = validate_file(filepath)
  return result unless result[:valid]
  
  receipt = {
    file: filepath,
    operation: operation,
    hash: result[:hash],
    timestamp: Time.now.iso8601,
    status: "COMPLETE"
  }
  
  # Log to receipt file
  FileUtils.mkdir_p("0ut.3ox")
  File.open("0ut.3ox/receipts.log", "a") do |f|
    f.puts "[#{receipt[:timestamp]}] #{operation} | #{filepath} | #{receipt[:hash]}"
  end
  
  # Route to destination
  destination = route_output(operation, receipt)
  receipt[:routed_to] = destination
  
  receipt
end

def run_test(operation = "knowledge_update")
  puts "=" * 60
  puts "3OX TESTRUN :: Ruby Runtime"
  puts "=" * 60
  
  # Load configuration
  tools = load_tools
  limits = load_limits
  brain = load_brain
  puts "\n✓ Brain: #{brain['name']} (#{brain['type']})"
  puts "✓ Rules: #{brain['rules'].take(3).join(', ')}"
  puts "✓ Tools loaded: #{tools.fetch('tools', []).length} available"
  puts "✓ Limits loaded: #{limits.dig('meta', 'version') || 'unknown'}"
  
  # Check file limits
  limit_check = check_file_limits(__FILE__)
  puts "\n✓ File size: #{limit_check[:file_size_mb]} MB / #{limit_check[:limit_mb]} MB"
  puts "✓ Within limits: #{limit_check[:within_limits]}"
  
  # Test file validation
  result = validate_file(__FILE__)
  puts "\n✓ File: #{result[:path]}"
  puts "✓ Hash: #{result[:hash]}"
  puts "✓ Size: #{result[:size]} bytes"
  
  # Generate receipt with custom operation
  receipt = generate_receipt(__FILE__, operation)
  puts "\n✓ Receipt: #{receipt[:status]}"
  puts "✓ Operation: #{operation}"
  puts "✓ Logged to: 0ut.3ox/receipts.log"
  puts "✓ Routed to: #{receipt[:routed_to]}"
  
  # Log to 3ox.log
  log_operation(operation, "COMPLETE", "Hash: #{result[:hash]}, Routed to: #{receipt[:routed_to]}")
  puts "✓ Operation logged to: 3ox.log"
  
  puts "\n" + "=" * 60
  puts "TEST COMPLETE"
  puts "=" * 60
  
  receipt
end

# ============================================================================
# Execute
# ============================================================================

def run_batch(operations)
  """Run multiple operations in one session"""
  operations.each do |operation|
    run_test(operation)
    puts ""  # Separator between operations
  end
end

if __FILE__ == $0
  # Check activation key FIRST
  check_activation_key
  
  if ARGV.length > 1
    # Batch mode: multiple operations
    run_batch(ARGV)
  else
    # Single mode
    operation = ARGV[0] || "knowledge_update"
    run_test(operation)
  end
end

