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
  end


end