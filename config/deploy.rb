# config valid only for current version of Capistrano
lock '3.4.0'

set :repo_url, 'git@github.com:gbotin/cap_deploy.git'

# Default branch is :master
set :branch, 'formation-1'
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :scm is :git
set :scm, :git

set :rbenv_type, :user
set :rbenv_ruby, '2.2.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :unicorn_pid, "#{shared_path}/tmp/pids/unicorn.pid"
set :unicorn_config, "config/unicorn.rb"

namespace :deploy do

  def run_unicorn
    within current_path do
      with rails_env: fetch(:rails_env) do
        execute :bundle, "exec unicorn -c #{fetch(:unicorn_config)} -D"
      end
    end
  end

  desc "Start Unicorn"
  task :start do
    on roles(:app) do
      run_unicorn
    end
  end

  desc 'Stop unicorn'
  task :stop do
    on roles(:app) do
      if test "[ -f #{fetch(:unicorn_pid)} ]"
        execute :kill, "-s QUIT `cat #{fetch(:unicorn_pid)}`"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      if test "[ -f #{fetch(:unicorn_pid)} ]"
        execute :kill, "-USR2 `cat #{fetch(:unicorn_pid)}`"
      else
        run_unicorn
      end
    end
  end

end
