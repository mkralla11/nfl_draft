Dir.glob(Rails.root.join('app/models/concerns/importer/*.rb')).each do |x| require x end
Dir.glob(Rails.root.join('app/models/concerns/draft/*.rb')).each do |x| require x end
Dir.glob(Rails.root.join('app/models/*.rb')).each do |x| require x end

namespace :draft_init do

  # delegate all import tasks to DraftProcessor, so the tasks
  # can be run out side of the application via command line,
  # as well as user-initiated import/restart of draft
  namespace :import do 
  desc "Importing all data"

    task :all => :environment do
      Draft::DraftBuilder.import_all
    end

    task :players => :environment do 
      Player.import_csv
    end

    task :teams => :environment do 
      Team.import_csv
    end

    task :order => :environment do 
      Order.import_csv
    end 

    task :site_configs => :environment do
      SiteConfig.init
    end
  end

  task :reset_all_tables => :environment do
    SiteConfig.reset_all_tables
  end

  task :restart_draft => :environment do
    SiteConfig.restart_draft!
  end


  task :simulate_draft => :environment do
    Draft::DraftProcessor::execute_full_draft
  end

end