require "bundler/capistrano"
require "whenever/capistrano"

set :application, "grams"
set :repository,  "git@github.com:joeyschoblaska/grams"
set :scm, :git
set :deploy_to, "/home/deploy/#{application}"
set :use_sudo, false
set :whenever_command, "bundle exec whenever"

ssh_options[:forward_agent] = true

role :app, 'deploy@joeyschoblaska.com'

namespace :deploy do
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && bundle exec whenever whenever --update-crontab #{application}"
  end
end

after 'deploy:update_code', 'deploy:update_crontab'
