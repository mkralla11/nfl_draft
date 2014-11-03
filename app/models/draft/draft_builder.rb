module Draft
  class DraftBuilder
    include Draft::Setup

    def self.init_json
      {
        :players => Player.undrafted,
        :teams => Team.with_drafts_left,
        :ownerships => Ownership.completed_drafts,
        :next_pick => Ownership.next_to_draft,
        :draft_state=>SiteConfig.draft_state, 
        :speed=>discern_speed
      }.to_json
    end


    def self.discern_speed
      $redis.get("speed").try(:to_f) || 2 
    end

  end
end