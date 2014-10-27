module Draft
  module Setup
    extend ActiveSupport::Concern
    module ClassMethods
      # Allow the DraftProcessor handle the import
      # of needed data within the app, I prefer not to
      # run rake tasks for user-initiated import of data,
      # It is much more messy to do something like
      # Rake::Task["build"].invoke ....yuck.
      # Also, SmartCsv has been used for csv importing,
      # mainly because of it's built-in chucking feature
      # that avoids loading big csv files into memory.
      # Finally, use activerecord-import to deal with
      # large insert to avoid a ton of create calls

      def import_all
        Player.import_csv
        Team.import_csv
        Ownership.import_csv
        SiteConfig.init
      end



    end
  end
end