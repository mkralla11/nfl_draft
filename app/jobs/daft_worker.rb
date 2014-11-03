class DraftWorker
  include SuckerPunch::Job

  def perform(params)
    params = JSON.parse(params)
    fail_safe_time = 17.minutes.from_now
    
    ActiveRecord::Base.connection_pool.with_connection do
      $redis.publish('draft.pub_live_start', params.to_json)
      SiteConfig.live_draft!

      while SiteConfig.live_draft? and Time.current < fail_safe_time and ownership = Team.make_next_draft!(params)
        $redis.publish('draft.pub_draft_made', params.merge(:ownership=>ownership, :next_pick=>Ownership.next_to_draft).to_json)
        sleep $redis.get("speed").to_f
      end

      if Ownership.has_drafts_left?
        $redis.publish('draft.pub_pause', params.to_json)
      else
        $redis.publish('draft.pub_draft_end', params.merge(:draft_state=>"stop").to_json)
        SiteConfig.end_draft!
      end
    end

  end

end