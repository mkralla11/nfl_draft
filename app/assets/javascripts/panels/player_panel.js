REALTIMEDRAFT.PlayerPanel = function(){
  "use strict";
  var self = this;
  self.element = $("<div class='player-panel base-panel'>");
  self.player_pods = {};
  var player_keys = [];
  bindListeners();


  function bindListeners(){
    REALTIMEDRAFT.es.addEventListener("draft.player_panel_init", function(e){
      var players_j = JSON.parse(e.data);
      for(var i = 0; i < players_j.length; i++){
        var id = players_j[i].player_id
        if(self.player_pods[id] == null){
          player_keys.push(id);
          self.player_pods[id] = new REALTIMEDRAFT.PlayerPod(players_j[i]);
          self.element.append(self.player_pods[id].element);
        }
      }
    })
  }


  self.popPlayerPod = function(attrs){
    var player = self.selectPlayerPod(attrs);
    if(player != null){
      delete self.selectPlayerPod(attrs);
      player.element.detach();
      return player;
    }
  }

  self.selectPlayerPod = function(attrs){
    return self.player_pods[attrs.player_id];
  }
};