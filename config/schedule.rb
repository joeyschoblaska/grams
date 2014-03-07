job_type :rake, "cd :path && bundle exec rake :task --trace --silent :output"

set :job_template, nil
set :output, "~/grams_cron.log"

every 1.hour do
  rake "delete_old_posts"
end

every 15.minutes do
  rake "update_active_posts"
end
