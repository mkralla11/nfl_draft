require 'resque/errors'
class DraftWorker
  @queue = :draft_worker_queue

  def self.perform(params)
    Rails.logger.info "\n\n\nProcess ID: #{Process.pid}\n\n\n"
    SiteConfig.set_worker_pid(Process.pid)
    params = JSON.parse(params)
    fail_safe_time = 8.minutes.from_now
    $redis.publish('draft.pub_live_start', params.to_json)
    while Time.current < fail_safe_time and ownership = Team.make_next_draft!(params)
      $redis.publish('draft.pub_draft_made', params.merge(:ownership=>ownership, :next_pick=>Ownership.next_to_draft).to_json)
      sleep $redis.get("speed").to_f
    end

    $redis.publish('draft.pub_draft_complete', params)

    rescue Resque::TermException
      $redis.publish('draft.pub_pause', params.to_json)
      SiteConfig.pause_draft!
  end

end