require 'resque/errors'
class DraftWorker
  # include Sidekiq::Worker
  @queue = :draft_worker_queue

  def self.perform(params)
    SiteConfig.set_worker_pid(Process.pid)
    params = JSON.parse(params)
    speed = params.try(:[], "speed").presence || 2.0
    speed = speed > 0.2 ? speed : 2.0
    fail_safe_time = 8.minutes.from_now
    while Time.current < fail_safe_time and ownership = Team.make_next_draft!(params)
      $redis.publish('draft.pub_draft_made', params.merge(:ownership=>ownership, :next_pick=>Ownership.next_to_draft).to_json)
      sleep speed
    end

    redis.publish('draft.pub_draft_complete', params)

    rescue Resque::TermException
      $redis.publish('draft.pub_pause', params.to_json)
      SiteConfig.pause_draft!
  end
end