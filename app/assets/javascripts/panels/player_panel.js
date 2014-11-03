REALTIMEDRAFT.PlayerPanel = function(){
  "use strict";
  var self = this;
  self.element = $("<div class='player-panel base-panel'>");
  self.player_pods = {};
  bindListeners();


  function bindListeners(){
    REALTIMEDRAFT.es.addEventListener("draft.init", function(e){
      var players_j = JSON.parse(e.data).players;
      disposeAllPods();
      initialize(players_j);
    })
  }

  function initialize(players_j){
    for(var i = 0; i < players_j.length; i++){
      var id = players_j[i].player_id
      if(self.player_pods[id] == null){
        self.player_pods[id] = new REALTIMEDRAFT.PlayerPod(players_j[i]);
        self.element.append(self.player_pods[id].element);
      }
    }
  }

  // when a user 'focuses' on a different tab in the
  // browser window, sse stops and then restarts
  // connection, missing a slew of potential drafts,
  // so here we remove all current pods and replace with
  // the new init json obj sent by server,
  // this also supplements with restart functionality
  function disposeAllPods(){
    for(var id in self.player_pods){
      if(self.player_pods.hasOwnProperty(id)){
        self.player_pods[id].dispose();
        self.player_pods[id] = null;
      }
    }
  }


  self.popPlayerPod = function(attrs){
    var player = self.selectPlayerPod(attrs);
    if(player != null){
      delete self.player_pods[attrs.player_id];
      player.element.detach();
      return player;
    }
  }

  self.selectPlayerPod = function(attrs){
    return self.player_pods[attrs.player_id];
  }
};