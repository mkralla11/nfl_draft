module Api
  module V1
    class DraftController < ApplicationController
      include ActionController::Live
      # around_filter :lock, :except=>:feed
      before_filter :draft_completion_filter, :only=>[:start, :update, :pause]

      # post
      def start
        if SiteConfig.can_start_draft?
          Draft::DraftProcessor.start(draft_params)
          render :json=>{"message"=>"success"}, :status=>:ok
        else
          render :json=>{:notice=>"The NFL Draft has already been started"}, :status=>422
        end
      end

      def update
        Draft::DraftProcessor.update(draft_params)
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

      end


      def feed
        response.headers['Content-Type'] = 'text/event-stream'
        sse = SSE.new(response.stream)

        begin
          Draft::DraftBuilder.build_all_panels(sse)
          Draft::DraftProcessor.bind_events(sse)
        rescue IOError
        # 
        ensure
          sse.close
        end
      end



      private
      def draft_completion_filter
        if Ownership.no_drafts_left?
          render :json=>{:notice=>"The NFL Draft is already finished. Please restart the NFL Draft to begin."}, :status=>422
          false
        end
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