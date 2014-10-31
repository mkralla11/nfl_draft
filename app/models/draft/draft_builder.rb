module Draft
  class DraftBuilder
    include Draft::Setup

    def self.init(sse, options={})
      ActiveRecord::Base.connection.query_cache.clear if options[:restart]
      self.player_panel_init(sse)
      self.ownership_panel_init(sse)
      self.team_panel_init(sse)
      self.control_panel_init(sse)
      self.info_panel(sse)
      self.startup(sse)
    end

    def self.player_panel_init(sse)
      sse.write(Player.undrafted.to_json, {event: 'draft.player_panel_init'})
    end

    def self.team_panel_init(sse)
      sse.write(Team.with_drafts_left.to_json, {event: 'draft.team_panel_init'})
    end  

    def self.ownership_panel_init(sse)
      sse.write(Ownership.completed_drafts.to_json, {event: 'draft.ownership_panel_init'})
    end

    def self.control_panel_init(sse)
      sse.write(self.control_panel_json, {event: 'draft.control_panel_init'})
    end

    def self.info_panel(sse)
      sse.write({:next_pick=>Ownership.next_to_draft}.to_json, {event: 'draft.info_panel_update'})
    end

    def self.startup(sse)
      sse.write({:next_pick=>Ownership.next_to_draft}.to_json, {event: 'draft.startup'})
    end

    def self.control_panel_json
      {:draft_state=>SiteConfig.draft_state, :speed=>discern_speed}.to_json
    end

    def self.discern_speed
      $redis.get("speed").try(:to_f) || 2 
    end
  end
end