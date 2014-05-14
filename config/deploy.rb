require "bundler/capistrano"
require "rvm/capistrano"

set :rvm_ruby_string, '2.1.0@rails410'
#set :rvm_bin_path, "/usr/local/rvm/bin"
#set :rvm_type, :user

set :application, "paperstencil"
set :repository,  "git@github.com:bitstat/paperstencil.git"

default_run_options[:pty] = true
set :deploy_to, "/var/paperstencil"
set :scm, :git
set :branch, "master"

## enable git checkout using ssh
set :ssh_options, {:forward_agent => true}

set :user, "root"
server "162.243.122.178", :app, :web, :db, :primary => true


namespace :god do
  task :start do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god -c config/paperstencil.god --log log/god.log"
  end

  task :reload do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god load config/paperstencil.god --log log/god.log"
  end

  task :stop do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god quit"
  end

  task :status do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god status"
  end

  task :restart do
    god.stop
    god.start
  end
end

namespace :unicorn do
  task :restart do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god restart unicorn"
  end

  task :stop do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god stop unicorn"
  end

  task :start do
    run "cd #{deploy_to}/current && rvmsudo bundle exec god start unicorn"
  end
end

namespace :nginx do
  task :reload do
    sudo "/etc/init.d/nginx reload"
  end
end


namespace :db do

  #desc "Syncs the database.yml file from the local machine to the remote machine"
  #task :sync_yaml do
  #  puts "\n\n=== Syncing database yaml to the production server! ===\n\n"
  #  unless File.exist?("config/database.yml")
  #    puts "There is no config/database.yml.\n "
  #    exit
  #  end
  #  system "rsync -vr --exclude='.DS_Store' config/database.yml #{user}@#{application}:#{shared_path}/config/"
  #end

  desc "Create Production Database"
  task :create do
    puts "\n\n=== Creating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:create RAILS_ENV=production"
  end

  desc "Migrate Production Database"
  task :migrate do
    puts "\n\n=== Migrating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
  end

  #desc "Resets the Production Database"
  #task :migrate_reset do
  #  puts "\n\n=== Resetting the Production Database! ===\n\n"
  #  run "cd #{current_path}; rake db:migrate:reset RAILS_ENV=production"
  #end
  #
  #desc "Destroys Production Database"
  #task :drop do
  #  puts "\n\n=== Destroying the Production Database! ===\n\n"
  #  run "cd #{current_path}; rake db:drop RAILS_ENV=production"
  #end
  #
  #desc "Moves the SQLite3 Production Database to the shared path"
  #task :move_to_shared do
  #  puts "\n\n=== Moving the SQLite3 Production Database to the shared path! ===\n\n"
  #  run "mv #{current_path}/db/production.sqlite3 #{shared_path}/db/production.sqlite3"
  #  system "cap deploy:setup_symlinks"
  #end

  desc "Populates the Production Database"
  task :seed do
    puts "\n\n=== Populating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  end

end

namespace :deploy do

  ## All existing connections will be honoured. New connections will be served using latest source code ##
  ## No down time from client perspective ##
  ## code is also updated
  task :reload do
    update
    god.restart
    run "cd #{deploy_to}/current && bundle exec rake db:migrate RAILS_ENV=production"
    unicorn.restart
    nginx.reload
  end

  ## Will be down time from client perspective ##
  ## Things will be terminated and restarted ##
  ## code is NOT updated
  task :restart, :roles => :app, :except => { :no_release => true } do
    unicorn.stop
    god.stop
    run "cd #{deploy_to}/current && bundle exec rake db:migrate RAILS_ENV=production"
    god.start # god will start unicorn, solr and resque
    nginx.reload
  end

  task :precache_assets do
    run "cd #{deploy_to}/current && bundle exec rake assets:precompile RAILS_ENV=production"
  end

  ## These image files are not part of asset pipeline. They need to be copied as it is ##
  task :copy_imagefiles do
    run "cd #{deploy_to}/current && cp app/assets/images/actions/16/*.png public/assets/actions/16/"
  end

  task :update_config do
    sudo "cp -f #{deploy_to}/current/config/deploy/nginx.conf /etc/nginx/nginx.conf"
    sudo "cp -f #{deploy_to}/current/config/deploy/paperstencil.com /etc/nginx/sites-enabled/paperstencil.com"
  end
end

#after 'deploy:update', 'deploy:precache_assets'
after 'deploy:update', 'deploy:copy_imagefiles'
after 'deploy:update', 'deploy:update_config'
