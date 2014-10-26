  # always make sure db is ready on app start
  MUTEX = Mutex.new

if !defined?(::Rake)
  Rails.application.configure do
    config.after_initialize do
      MUTEX.synchronize do
        unless SiteConfig.draft_start_date.persisted?
          SiteConfig.reset_all
          SiteConfig.init
          Draft::DraftBuilder.import_all
        end
      end
    end
  end
end
