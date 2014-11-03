module Api
  module V1
    class DraftController < ApplicationController
      include ActionController::Live
      # around_filter :lock, :except=>:feed
      before_filter :draft_completion_filter, :only=>[:start, :update, :pause]
      before_filter :setup_header, :setup_sse, :setup_redis, :disconnect_db, :only=>:feed

      # post
      def start
        if SiteConfig.can_start_draft?
          Draft::DraftProcessor.start(draft_params)
          render :json=>{"message"=>"success"}, :status=>:ok
        else
          render :json=>{:notice=>"The NFL Draft has already been started"}, :status=>422
        end
      end

      def update_speed
        Draft::DraftProcessor.update_speed(draft_params)
        render :json=>{"message"=>"success"}, :status=>:ok
      end

      # post
      def pause
        if SiteConfig.can_pause_draft?
          Draft::DraftProcessor.pause(draft_params)
          render :json=>{"message"=>"success"}, :status=>:ok
        else
          render :json=>{:notice=>"The NFL Draft must be running automatically to be paused."}, :status=>422
        end
      end

      # post
      def restart
        if SiteConfig.can_restart_draft?
          Draft::DraftProcessor.restart(draft_params)
          render :json=>{"message"=>"success"}, :status=>:ok
        else
          render :json=>{:notice=>"The draft could not be restarted. Please pause the draft before restarting."}, :status=>422
        end
      end


      def feed
        Draft::DraftProcessor.init(@sse)

        heart_beat = Thread.new { loop { @sse.write 0; sleep 5 } }
        publisher = Thread.new do
          Draft::DraftProcessor.bind_events(@sse, @redis)
        end

        heart_beat.join
        publisher.join

      rescue IOError
      # 
      ensure
        Thread.kill(heart_beat) if heart_beat
        Thread.kill(publisher) if publisher

        @redis.quit
        @sse.close
      end



      private
      def draft_completion_filter
        if Ownership.no_drafts_left?
          render :json=>{:notice=>"The NFL Draft is already finished. Please restart the NFL Draft to begin."}, :status=>422
          false
        end
      end

      def setup_header
        response.headers['Content-Type'] = 'text/event-stream'
      end

      def setup_sse
        @sse = SSE.new(response.stream)
      end

      def setup_redis
        @redis = Redis::Namespace.new("nfl_draft", :redis => Redis.new(:url => $redis_uri))
      end

      def disconnect_db
        ActiveRecord::Base.connection_pool.release_connection
      end 

      def lock
        MUTEX.synchronize do
          yield
        end
      end

      # faster than strong params
      def draft_params
        @draft_params ||= params.slice("speed", "manual", "single", "pick-type")
      end

    end
  end
end