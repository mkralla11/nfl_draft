# NflDraft

An Nfl Draft application demonstrating server sent events, redis, and an event driven, frameworkless frontend facilated by the jQuery library.

## Installation

Please ensure the following are installed and working properly:

    *  Redis
      * osx: $ brew install redis
              <!-- open 2 new terminal tabs/cmd's and run one command on each -->
             $ redis-server /usr/local/etc/redis.conf
             $ env TERM_CHILD=1 QUEUE=* INTERVAL=1 bundle exec rake resque:work


## Usage

This app uses Puma as the web server. The app needs a persistent way to update all clients when the draft is occuring, so server sent events was the means to achieve this (web sockets seemed like overkill). Puma allows for true concurrency for rails, which is needed for these realtime features.

to start this app, run:

rails s Puma



