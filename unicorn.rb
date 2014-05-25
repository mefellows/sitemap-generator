# Set the working application directory
# working_directory "/path/to/your/app"
# working_directory "/var/www/my_app"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path "unicorn-error.log"
stdout_path "unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.sitemap.sock"

# Number of processes
worker_processes 4

# Time-out
timeout 30