module Draft
  class DraftProcessor

    def self.bind_events(sse)
      redis = Redis.new
      redis.psubscribe('draft.*') do |on|
        on.pmessage do |pattern, event, data|
          self.dispatch(event, sse, data)
        end
      end
    end


    def self.dispatch(event, sse, data)
      params = JSON.parse(data)
      pub = event.split(".").last.to_sym
      self.send(pub, sse, params) if respond_to? pub
    end

    # start method handles single manual,
    # single random, and "live" drafting
    # dispatching accordingly
    def self.start(params)
      if Ownership.has_drafts_left?
        # only send official start message when draft start date is blank
        $redis.publish('draft.pub_start', params.to_json) unless SiteConfig.draft_in_progress?
        SiteConfig.start_draft!
        if params["single"] == "true"
          ownership = Team.make_next_draft!(params)
          $redis.publish('draft.pub_draft_made', params.merge(:ownership=>ownership, :next_pick=>Ownership.next_to_draft).to_json)
          SiteConfig.pause_draft!
        else
          DraftWorker.perform_async(params.to_json)
        end
      else
        $redis.publish('draft.pub_completed', params.to_json)
      end
    end

    def self.pause(params)
      worker_pid = SiteConfig.worker_pid.as_integer
      Process.kill("TERM", worker_pid)
    end

    def self.update(params)
      
    end

    private
    # All of the methods below handle
    # publishing what just occured to all sse users
    def self.pub_start(sse, params)
      # pub_start event params will not contain
      # who was drafted, only draft status information
      sse.write(params.to_json, {event: 'draft.pub_start'})
    end

    def self.pub_update(sse, params)

    end

    def self.pub_pause(sse, params)
      sse.write(params.to_json, {event: 'draft.pub_pause'})
    end


    def self.pub_draft_made(sse, params)
      # pub_draft_made event params include
      # draft status info AND who was drafted
      sse.write(params.to_json, {event: 'draft.pub_draft_made'})
      sse.write(params.to_json, {event: 'draft.info_panel_update'})
    end

    def self.pub_completed(sse, params)
      # pub_draft_made event params include
      # draft status info AND who was drafted
      sse.write(params.to_json, {event: 'draft.pub_completed'})
    end

  end
end