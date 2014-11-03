REALTIMEDRAFT.TeamPanel = function(){
  "use strict";
  var self = this;
  self.element = $("<div class='team-panel base-panel'>");
  // object id_of_team => team_pod_obj
  self.team_pods = {};
  bindListeners();


  function bindListeners(){
    REALTIMEDRAFT.es.addEventListener("draft.init", function(e){
      var teams_j = JSON.parse(e.data).teams;
      disposeAllPods();
      initialize(teams_j);
      $(self).trigger("team_panel.initialized");
    })
  };


  function initialize(teams_j){
      for(var i = 0; i < teams_j.length; i++){
        var id = uniqKey(teams_j[i]);
        if(self.team_pods[id] == null){
          self.team_pods[id] = new REALTIMEDRAFT.TeamPod(teams_j[i]);
          self.element.append(self.team_pods[id].element);
        }
      };
  }

  // when a user 'focuses' on a different tab in the
  // browser window, sse stops and then restarts
  // connection, missing a slew of potential drafts,
  // so here we remove all current pods and replace with
  // the new init json obj sent by server
  function disposeAllPods(){
    for(var id in self.team_pods){
      if(self.team_pods.hasOwnProperty(id)){
        self.team_pods[id].dispose();
        self.team_pods[id] = null;
      }
    }
  }



  self.popTeamPod = function(attrs){
    var team = self.selectTeamPod(attrs);
    if(team != null){
      delete self.team_pods[uniqKey(attrs)];
      team.element.detach();
      return team;
    }
  }

  self.selectTeamPod = function(attrs){
    if(attrs == null || attrs.team_id == null){return null};
    return self.team_pods[uniqKey(attrs)];
  }

  function uniqKey(attrs){
    return "" + attrs.team_id + "-" + attrs.pick
  }
};
