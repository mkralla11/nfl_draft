REALTIMEDRAFT.TeamPanel = function(){
  "use strict";
  var self = this;
  self.element = $("<div class='team-panel base-panel'>");
  // object id_of_team => team_pod_obj
  self.team_pods = {};
  bindListeners();


  function bindListeners(){
    REALTIMEDRAFT.es.addEventListener("draft.team_panel_init", function(e){
      var teams_j = JSON.parse(e.data);
      for(var i = 0; i < teams_j.length; i++){
        var id = uniqKey(teams_j[i]);
        if(self.team_pods[id] == null){
          self.team_pods[id] = new REALTIMEDRAFT.TeamPod(teams_j[i]);
          self.element.append(self.team_pods[id].element);
        }
      };
      $(self).trigger("team_panel.initialized");
    })

    REALTIMEDRAFT.es.addEventListener("draft.pub_draft_made", function(e){
      console.log(e.data + " TeamPanel");
    });
  };



  self.popTeamPod = function(attrs){
    var team = self.selectTeamPod(attrs);
    if(team != null){
      delete self.selectTeamPod(attrs);
      team.element.detach();
      return team;
    }
  }

  self.selectTeamPod = function(attrs){
    return self.team_pods[uniqKey(attrs)];
  }

  function uniqKey(attrs){
    return "" + attrs.team_id + "-" + attrs.pick
  }
};
