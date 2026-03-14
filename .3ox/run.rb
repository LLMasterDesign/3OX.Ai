#!/usr/bin/env ruby
# status:[ACTIVE] ver:[1.0.0] created:[26.03.09]
# doc:[PARTIAL] modified:[26.03.09] auth:[3OX.AI]
# Root 3OX launcher and single-process station supervisor.

require 'json'
require 'fileutils'
require 'time'

ROOT = File.expand_path('..', __dir__)
PULSE_ROOT = File.join(__dir__, '(6)Pulse')
RUNTIME = File.join(PULSE_ROOT, 'runtime')
QUEUE_DIR = File.join(RUNTIME, 'queue')
LOG_DIR = File.join(RUNTIME, 'logs')
PID_FILE = File.join(RUNTIME, 'station.pid')
STATUS_FILE = File.join(RUNTIME, 'status.json')
QUEUE_FILE = File.join(QUEUE_DIR, 'jobs.json')
ACTIVITY_LOG = File.join(LOG_DIR, 'station.log')

HEARTBEAT_SECONDS = (ENV['THREEOX_HEARTBEAT_SECONDS'] || '5').to_i
MAX_STREAM_LINES = (ENV['THREEOX_STREAM_LINES'] || '5').to_i

FileUtils.mkdir_p([RUNTIME, QUEUE_DIR, LOG_DIR])

def now
  Time.now.utc.iso8601
end

def load_json(path, fallback)
  return fallback unless File.exist?(path)

  JSON.parse(File.read(path))
rescue JSON::ParserError
  fallback
end

def write_json(path, data)
  File.write(path, JSON.pretty_generate(data))
end

def append_log(message)
  File.open(ACTIVITY_LOG, 'a') { |f| f.puts("[#{now}] #{message}") }
end

def base_status
  {
    'updated_at' => now,
    'mode' => 'idle',
    'queue_depth' => 0,
    'active_job' => nil,
    'last_completed_job' => nil,
    'services' => {
      'spark' => 'idle',
      'brains' => 'idle',
      'rules' => 'idle',
      'toolkit' => 'idle',
      'links' => 'idle',
      'pulse' => 'idle'
    }
  }
end

def update_status
  status = load_json(STATUS_FILE, base_status)
  yield(status)
  status['updated_at'] = now
  write_json(STATUS_FILE, status)
end

def load_queue
  data = load_json(QUEUE_FILE, { 'jobs' => [] })
  data['jobs'] ||= []
  data
end

def save_queue(data)
  write_json(QUEUE_FILE, data)
end

def enqueue_job(command, args)
  queue = load_queue
  job_id = "job-#{Time.now.to_i}-#{rand(1000..9999)}"
  job = {
    'id' => job_id,
    'command' => command,
    'args' => args,
    'created_at' => now,
    'status' => 'queued'
  }
  queue['jobs'] << job
  save_queue(queue)
  update_status { |s| s['queue_depth'] = queue['jobs'].size }
  append_log("queued #{job_id} command=#{command} args=#{args.join(' ')}")
  job
end

def shift_job
  queue = load_queue
  job = queue['jobs'].shift
  save_queue(queue)
  update_status { |s| s['queue_depth'] = queue['jobs'].size }
  job
end

def mark_services(mode)
  update_status do |s|
    s['mode'] = mode
    s['services'].keys.each { |key| s['services'][key] = mode }
  end
end

def stream_progress(job, line)
  append_log("stream #{job['id']} :: #{line}")
  puts "[stream] #{line}"
end

def run_job(job)
  update_status do |s|
    s['mode'] = 'active'
    s['active_job'] = job
    s['services'] = {
      'spark' => 'active',
      'brains' => 'active',
      'rules' => 'monitoring',
      'toolkit' => 'active',
      'links' => 'reporting',
      'pulse' => 'active'
    }
  end

  append_log("active #{job['id']} command=#{job['command']}")

  output = []
  case job['command']
  when 'teleprompt', 'analyze'
    pulse_runner = File.join(PULSE_ROOT, 'run.rb')
    cmd = ['ruby', pulse_runner, job['command'], *job['args']]
    IO.popen(cmd + ['2>&1'], err: [:child, :out]) do |io|
      io.each_line do |line|
        clean = line.strip
        next if clean.empty?

        output << clean
        stream_progress(job, clean) if output.size <= MAX_STREAM_LINES
      end
    end
    success = $?.success?
  when 'noop'
    3.times do |i|
      line = "heartbeat-step=#{i + 1}/3"
      output << line
      stream_progress(job, line)
      sleep 1
    end
    success = true
  else
    output << "unknown command '#{job['command']}'"
    success = false
  end

  result = {
    'job_id' => job['id'],
    'completed_at' => now,
    'status' => success ? 'completed' : 'failed',
    'output_preview' => output.first(MAX_STREAM_LINES)
  }

  write_json(File.join(LOG_DIR, "#{job['id']}.json"), result)

  queue = load_queue
  update_status do |s|
    s['mode'] = 'idle'
    s['active_job'] = nil
    s['queue_depth'] = queue['jobs'].size
    s['last_completed_job'] = result
    s['services'].keys.each { |key| s['services'][key] = 'idle' }
  end

  append_log("#{result['status']} #{job['id']}")
end

def station_running?
  return false unless File.exist?(PID_FILE)

  pid = File.read(PID_FILE).to_i
  return false if pid <= 0

  Process.kill(0, pid)
  true
rescue Errno::ESRCH, Errno::EPERM
  false
end

def start_station
  if station_running?
    puts "station already running (pid=#{File.read(PID_FILE).strip})"
    return
  end

  pid = fork do
    Process.setsid
    stdout_log = File.open(ACTIVITY_LOG, 'a')
    $stdout.reopen(stdout_log)
    $stderr.reopen(stdout_log)
    $stdout.sync = true
    $stderr.sync = true

    trap('TERM') { exit(0) }
    trap('INT') { exit(0) }

    File.open(PID_FILE, 'w') { |f| f.puts(Process.pid) }
    append_log('station started')
    mark_services('standby')

    loop do
      job = shift_job
      if job
        run_job(job)
      else
        update_status do |s|
          s['mode'] = 'idle'
          s['services']['pulse'] = 'watching'
        end
        append_log('heartbeat idle')
        sleep HEARTBEAT_SECONDS
      end
    end
  ensure
    FileUtils.rm_f(PID_FILE)
    append_log('station stopped')
  end

  Process.detach(pid)
  puts "station started (pid=#{pid})"
end

def stop_station
  unless station_running?
    puts 'station not running'
    return
  end

  pid = File.read(PID_FILE).to_i
  Process.kill('TERM', pid)
  puts "stop signal sent to pid=#{pid}"
end

def show_status
  status = load_json(STATUS_FILE, base_status)
  puts JSON.pretty_generate(status)
end


def run_once(command, args)
  job = {
    'id' => "job-#{Time.now.to_i}-#{rand(1000..9999)}",
    'command' => command,
    'args' => args,
    'created_at' => now,
    'status' => 'active'
  }
  run_job(job)
  show_status
end

command = ARGV[0]
args = ARGV[1..]

case command
when 'start'
  start_station
when 'stop'
  stop_station
when 'status'
  show_status
when 'queue'
  command_name = args[0] || 'noop'
  command_args = args[1..]
  job = enqueue_job(command_name, command_args)
  puts "queued #{job['id']}"
when 'once'
  command_name = args[0] || 'noop'
  command_args = args[1..]
  run_once(command_name, command_args)
when 'teleprompt', 'analyze'
  run_once(command, args)
when 'aliveness'
  exec('ruby', File.join(ROOT, '.vec3', 'rc', 'run.rb'), 'aliveness')
else
  puts <<~USAGE
    Usage: ruby .3ox/run.rb [start|stop|status|queue|once|teleprompt|analyze|aliveness]

    start                      # start station supervisor loop in background
    stop                       # stop station supervisor loop
    status                     # show current status json
    queue <cmd> [args...]      # enqueue a job (cmd: noop|teleprompt|analyze)
    once <cmd> [args...]       # run one job synchronously
    teleprompt [args...]       # convenience wrapper (once teleprompt)
    analyze [args...]          # convenience wrapper (once analyze)
    aliveness                  # delegate to .vec3/rc/run.rb aliveness
  USAGE
  exit 1
end
