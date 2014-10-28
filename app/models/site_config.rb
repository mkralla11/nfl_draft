class SiteConfig < ActiveRecord::Base
  APPROVED = [ :draft_start_date, :draft_end_date, :draft_state, :worker_pid]

  APPROVED.each do |name|
    name = name.to_s
    n = name + "?"
    [n, name].each do |meth|
      # handles chaining, if site config was not created
      define_singleton_method(meth) { find_by(:name=>name).presence || SiteConfig.new }
    end
  end

  validates_presence_of :name
  validates_uniqueness_of :name
  validate :approved_name?

  def self.reset_all_tables
    ActiveRecord::Base.descendants.each do |model|
      next if model.table_name == "schema_migrations"
      model.empty_and_reset_table
    end
  end

  # updater_id = 0 equals site created it
  def self.init
    persisted_names = where(array_attr_pred_sql(APPROVED, "name", "in")).pluck(:name);
    needed_names = APPROVED - persisted_names
    ActiveRecord::Base.transaction do
      attrs = needed_names.collect do |name| 
        self.create(:name=>name.to_s)
      end
    end
  end


  def approved_name?
    if !SiteConfig.respond_to? name.to_sym
      errors.add :name, "'#{name}' is not approved."
    end
  end

  def self.set_worker_pid(pid)
    SiteConfig.worker_pid.update_column(:as_integer, pid)
  end

  # could have used state_machine gem for this,
  # but figured it was overkill, I also am not
  # a huge fan of using that gem because too
  # many times I have see it ruin a project
  # due to miss-use/overuse of callbacks
  def self.start_draft!
    SiteConfig.draft_start_date.update_column(:as_datetime, DateTime.now) if SiteConfig.draft_state.as_string.blank?
    SiteConfig.draft_state.update_column(:as_string, "start")
  end

  def self.pause_draft!
    SiteConfig.draft_state.update_column(:as_string, "pause")
  end


  # does NOT drop all records, simply wipes start date of draft in site config,
  # and wipes picked_at and player_id from ownership
  def self.restart_draft!
    SiteConfig.draft_start_date.update_column(:as_datetime, nil)
    Ownership.update_all(:picked_at=>nil, :player_id=>nil)
    SiteConfig.draft_state.update_column(:as_string, "stop")
  end

  def self.can_start_draft?
    SiteConfig.draft_stopped? or SiteConfig.draft_paused?
  end

  def self.can_pause_draft?
    SiteConfig.draft_started?
  end

  def self.can_restart_draft?
    SiteConfig.draft_paused?
  end

  def self.draft_in_progress?
    SiteConfig.draft_paused? or SiteConfig.draft_started?
  end


  def self.draft_started?
    SiteConfig.draft_state.as_string == "start"
  end


  def self.draft_paused?
    SiteConfig.draft_state.as_string == "pause"
  end

  def self.draft_stopped?
    SiteConfig.draft_state.as_string.blank? or SiteConfig.draft_state.as_string == "stop"
  end
end