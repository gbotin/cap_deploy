app_dir = '/home/deploy/cap_deploy/current'

worker_processes 3
timeout 15
preload_app true

working_directory app_dir

listen "#{app_dir}/tmp/sockets/unicorn.sock", backlog: 64

pid "#{app_dir}/tmp/pids/unicorn.pid"

stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

before_fork do |server, worker|

  defined?(ActiveRecord::Base) and  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{app_dir}/Gemfile"
end
