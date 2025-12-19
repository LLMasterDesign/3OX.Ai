#!/usr/bin/env ruby
# Setup new .3ox folder from templates

require 'fileutils'

def setup_3ox(target_dir, agent_name, brain_type)
  dot3ox = File.join(target_dir, ".3ox")
  FileUtils.mkdir_p(dot3ox)
  
  # Copy templates
  templates = File.join(File.dirname(__FILE__), "TEMPLATES")
  FileUtils.cp("#{templates}/brains.rs", "#{dot3ox}/brains.rs")
  FileUtils.cp("#{templates}/tools.yml", "#{dot3ox}/tools.yml")
  FileUtils.cp("#{templates}/limits.toml", "#{dot3ox}/limits.toml")
  FileUtils.cp("#{templates}/routes.json", "#{dot3ox}/routes.json")
  FileUtils.cp("#{templates}/run.rb", "#{dot3ox}/run.rb")
  FileUtils.cp("#{templates}/sparkfile.md", "#{dot3ox}/sparkfile.md")
  
  # Customize brains.rs
  brain_content = File.read("#{dot3ox}/brains.rs")
  brain_content.gsub!("AGENT_NAME", agent_name)
  brain_content.gsub!("BrainType::Sentinel", "BrainType::#{brain_type}")
  File.write("#{dot3ox}/brains.rs", brain_content)
  
  # Customize sparkfile.md
  sparkfile_content = File.read("#{dot3ox}/sparkfile.md")
  sparkfile_content.gsub!("AGENT_NAME", agent_name)
  sparkfile_content.gsub!("AGENT_ID", agent_name.upcase)
  sparkfile_content.gsub!("WORKSPACE_PATH", target_dir)
  sparkfile_content.gsub!("agent.domain", "general")
  # Get Sirius time - try workspace root first, then fallback
  workspace_root = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", ".."))
  sirius_script = File.join(workspace_root, "sirius.clock.rb")
  sirius_time = if File.exist?(sirius_script)
    `cd "#{workspace_root}" && ruby sirius.clock.rb 2>/dev/null`.strip
  else
    `ruby sirius.clock.rb 2>/dev/null`.strip
  end
  sirius_time = "⧗-25.131" if sirius_time.empty?
  sparkfile_content.gsub!("⧗-YY.SSS", sirius_time)
  File.write("#{dot3ox}/sparkfile.md", sparkfile_content)
  
  puts "✓ .3ox system created at #{dot3ox}"
  puts "✓ Agent: #{agent_name}"
  puts "✓ Type: #{brain_type}"
  puts "✓ Sparkfile created"
  puts "✓ Templates deployed"
end

if ARGV.length < 3
  puts "Usage: ruby setup-3ox.rb <target_dir> <agent_name> <brain_type>"
  puts "Example: ruby setup-3ox.rb MyProject GUARDIAN Sentinel"
  exit 1
end

setup_3ox(ARGV[0], ARGV[1], ARGV[2])

