module Draft
  class DraftProcessor
    include Draft::FullDrafter

    def self.bind_events(sse)
      redis = Redis::Namespace.new("nfl_draft", :redis => Redis.new)
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
    # single random, and automatic drafting
    # dispatching accordingly
    def self.start(params)
      if Ownership.has_drafts_left?
        # only send official start message when draft start date is blank
        $redis.publish('draft.pub_start', params.to_json) unless SiteConfig.draft_in_progress?
        SiteConfig.start_draft!
        if params["single"] == "true"
          self.single_draft(params)
        else
          process_speed(params)
          Resque.enqueue(DraftWorker, params.to_json)
        end
      else
        $redis.publish('draft.pub_completed', params.to_json)
      end
    end

    def self.update_speed(params)
      process_speed(params)
      $redis.publish('draft.pub_update_speed', params.to_json)
    end

    def self.pause(params)
      worker_pid = SiteConfig.worker_pid.as_integer
      Process.kill("TERM", worker_pid)
    end

    def self.single_draft(params)
      ownership = Team.make_next_draft!(params)
      $redis.publish('draft.pub_draft_made', params.merge(:ownership=>ownership, :next_pick=>Ownership.next_to_draft).to_json)
      SiteConfig.pause_draft!
      $redis.publish('draft.pub_pause', {}.to_json);
    end


    def self.restart(params)
      SiteConfig.restart_draft!
      $redis.publish('draft.pub_restart', params.to_json)
    end
    



    # All of the methods below handle
    # publishing what just occured to all sse users
    def self.pub_start(sse, params)
      # pub_start event params will not contain
      # who was drafted, only draft status information
      sse.write(params.to_json, {event: 'draft.pub_start'})
    end

    def self.pub_update_speed(sse, params)
      sse.write(params.to_json, {event: 'draft.pub_update_speed'})
    end

    def self.pub_pause(sse, params)
      sse.write(params.to_json, {event: 'draft.pub_pause'})
    end


    def self.pub_restart(sse, params)
      Draft::DraftBuilder.init(sse, {:restart=>true})
    end

    def self.pub_draft_made(sse, params)
      # pub_draft_made event params include
      # draft status info AND who was drafted
      sse.write(params.to_json, {event: 'draft.pub_draft_made'})
      sse.write(params.to_json, {event: 'draft.info_panel_update'})
    end

    def self.pub_live_start(sse, params)
      sse.write(params.to_json, {event: 'draft.pub_live_start'})
    end

    def self.pub_completed(sse, params)
      sse.write(params.to_json, {event: 'draft.pub_completed'})
    end

    def self.process_speed(params)
      speed = params.try(:[], "speed").presence || $redis.get("speed") || 2.0
      speed = speed.to_f >= 0.7 ? speed : 2.0
      $redis.set("speed", speed)
      params["speed"] = speed
    end
  end
end