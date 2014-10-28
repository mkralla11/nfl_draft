# Realtime NFL Draft

An Nfl Draft application demonstrating the use of ActionController::Live, Server Sent Events, Redis, and an event driven, frameworkless frontend facilated by the jQuery library.

## Notes

The goal of this application was to explore newer rails features, as well as
explore other lesser known yet awesome parts of rails. I wanted to be able
to allow users to experience a nfl draft as it would occur in the real world,
meaning all users 'watching' the draft should see the draft actually happening.

This app uses Puma as the web server. The app needs a persistent way to update all clients when the draft is occurring, so server sent events was the means to achieve this (web sockets seemed like overkill). Puma allows for true concurrency for rails, which is needed for these real-time features.

Redis is used for its excellent pub/sub implementation. This, combined with the new ActionController::Live and Server Sent Events, allows for a powerful constant feed to clients. Finally, the use of Resque allows the NFL draft to continue even if the original client who initiated the live draft leaves (closes his/her browser). In that case, the draft will continue without a hiccup for all other subscribed clients just like a real 'live' event.

On the frontend, I felt that js frameworks like Angular or Ember didn't fit the mold of this unique implementation. So I build the frontend from scratch in a well encapsulated, object-oriented manner. I made sure not to pollute the global namespace, as well as explicitly make sure garbage collection could occur on processed/unused objects. jQuery was used simply for it's excellent DOM traversal functions, and animation. By not tying myself to a large framework, the frontend is much lighter, which is crucial if a very fast draft speed is set and a live draft is currently in progress.

Also, when I am writing the initial plans for my frontend code, I usually make sure to target the desktop and mobile browsing experiences in one go, rather than going back and rewriting one or the other. In this case, I only targeted desktop and tablets, as my goal was to showcase my research and implement on newer technologies listed above, not so much demonstrate my responsive layout abilities (although it is usually of great importance to me).

If I could go back and redo the application, one thing I would change is changing calls to jQuery's 'animate' method to a sequentially stepped call to jQuery's css method. That way I would be able to implement the Realtime Draft Timeline slider, which would allow the traversal from the current draft, all the way 'back in time' to previous drafts. Now that would be cool.

With regards to Mutex usage in the application, I needed to make sure all requests to all actions were serial, EXCEPT for the feed method. That way I could ensure that race conditions to stop/pause/restart/etc the draft would not end up in a dead lock or missing drafts, while at the same time feed every single published event to all clients smoothly, without locking up.

I did test out Sidekiq in place of Resque, but then soon realized the big hype about Sidekiq was due to the fact that it used threads instead of processes. This actually did not benefit me, because even if this app scaled to a huge global website, each draft should only have on 'worker process' to handle the live drafting feature. Therefore, multiple threads just didn't make sense.

As for bugs, I witnessed only two. The first was when a user changes tabs while a draft is occurring, and then switches back to the live draft. This has to do with the SSE connection sometimes 'reconnecting' randomly on browser tab switching, causing a re-init of the app. I was able to mitigate that problem with some simple checks. Along those same lines, the queue I implemented on the frontend would build up when a user switched tabs, and then when they refocused the draft tab and paused the draft, the queue would continue dispersing the remaining drafts in the queue (not really an issue, as this is what 'should' technically happen). The second bug occurred when I manually stopped and restarted the server. Obviously this wouldn't happen (regularly) in a solid production environment, and even if it did, proper deployment strategies would be in place to swap out live draft workers correctly (currently outside the scope of this app).


Follow the installation steps, then the usage steps to begin:


## Installation

Please ensure the following are installed and working properly:
  * ruby 2.1.2
  * rails 4.1.4

run these commands next (some are osx specific commands; sub pc commands where necessary):
  * $ brew install redis
  * $ bundle install
  * $ bundle exec rake db:create
  * $ bundle exec rake db:migrate

Do not worry about importing the data with importer rake tasks, see Tasks section for more info, please continue with the follow instructions:

Having 3 tabs/cmds/terminals new terminal tabs/cmd's and run one command on each:
  * $ redis-server /usr/local/etc/redis.conf
  * $ env TERM_CHILD=1 QUEUE=* INTERVAL=1 bundle exec rake resque:work
  * $ rails s puma

Now, to enjoy the live viewing experience:
  * open TWO (or three) separate browser windows, side by side, and navigate to localhost:3000
  * click the Single Random Draft button a few times and see individual drafts be made by the respective current team.
  * click the Continue Live Draft button to see the draft begin, publishing all results to every subscribed user.
  * change the speed slider of the draft while it is running....yeah, that just happened.
  * notice the slider update on the other window as well as update the actual speed.
  * pause the draft via the Pause Live Draft button. All movement will stop.
  * restart the draft via the Restart Draft button.
  * let what just happened sink in. Rinse and repeat the awesomeness.

## Tasks

There's no need to run any of the importer tasks because the app initializes the database on server start. Why would you let your app start without any essential seed data? 

There are a surplus of tasks that can be explore if you so desire (the names should be pretty self-explanatory):

* draft_init:reset_all_tables
* draft_init:import:all
* draft_init:import:players
* draft_init:import:teams
* draft_init:import:order
* draft_init:import:site_configs
* draft_init:simulate_draft
* draft_init:restart_draft


