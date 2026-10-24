#!/usr/bin/env ruby

# 3OX Finance Agent
# Sample agent for testing the 3OX SETS Viewer

puts "Starting 3OX Finance Agent..."
puts "Agent ID: #{ENV['AGENT_ID']}"
puts "Agent Home: #{ENV['AGENT_HOME']}"
puts "Free Mode: #{ENV['3OX_FREE_MODE']}"

# Simulate agent work
loop do
  puts "[#{Time.now}] Finance Agent: Processing market data..."
  sleep 10
end