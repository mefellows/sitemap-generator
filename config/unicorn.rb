# Set the working application directory
# working_directory "/path/to/your/app"
# working_directory "/var/www/my_app"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
# pid "unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
# stderr_path "unicorn-error.log"
# stdout_path "unicorn.log"

# Unicorn socket
# listen "/tmp/unicorn.sitemap.sock"

# Number of processes
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 4)

# Time-out
timeout 300

preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
  # ...
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end
  # ...
end