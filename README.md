# NflDraft

An Nfl Draft application demonstrating server sent events, redis, and an event driven, frameworkless frontend facilated by the jQuery library.

## Notes

The goal of this application was to explore newer rails features, as well as
explore other lesser known yet awesome parts of rails. I wanted to be able
to allow users to experience a nfl draft as it would occur in the real world,
meaning all users 'watching' the draft should see the draft actually happening.

Follow the installation steps, then the usage steps to begin:


## Installation

Please ensure the following are installed and working properly:
    * ruby 2.1.2
    * rails 4.1.4
    * $ bundle install

    *  Redis
      * osx: $ brew install redis
              <!-- open 2 new terminal tabs/cmd's and run one command on each -->
             $ redis-server /usr/local/etc/redis.conf
             $ env TERM_CHILD=1 QUEUE=* INTERVAL=1 bundle exec rake resque:work


## Usage

run these commands:
    * $ bundle exec rake db:create
    * $ bundle exec rake db:migrate

## Tasks

There's no need to run any of the importer tasks because the app initializes the database on server start. Why would you let your app start without any data? 

There are a surplus of tasks that can be explore if you so desire (the names should be pretty self-explanatory):

draft_init:reset_all_tables
draft_init:import:all
draft_init:import:players
draft_init:import:teams
draft_init:import:order
draft_init:import:site_configs
draft_init:simulate_draft
draft_init:restart_draft


This app uses Puma as the web server. The app needs a persistent way to update all clients when the draft is occuring, so server sent events was the means to achieve this (web sockets seemed like overkill). Puma allows for true concurrency for rails, which is needed for these realtime features.

to start this app, run:

rails s puma

To enjoy the live viewing experience:
  * open TWO browser windows, side by side, and navigate to localhost:3000
  * click the Single Random Draft button and see one draft be made by the current team
  * click the Continue Live Draft button to see the draft begin, publishing all results to every subscribed user.
  * change the speed slider of the draft while it is running....awesomeness.
  * notice the slide update on the other window as well.
  * pause the draft.

