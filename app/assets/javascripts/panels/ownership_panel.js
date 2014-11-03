REALTIMEDRAFT.OwnershipPanel = function(){
  "use strict";
  var self = this;
  this.element = $("<div class='ownership-panel base-panel'>");
  this.ownership_pods = {};
  bindListeners();



  function bindListeners(){
    REALTIMEDRAFT.es.addEventListener("draft.init", function(e){
      var ownerships_j = JSON.parse(e.data).ownerships;
      disposeAllPods();
      initialize(ownerships_j);
    })
  }


  function initialize(ownerships_j){
    for(var i = 0; i < ownerships_j.length; i++){
      var id = ownerships_j[i].ownership_id
      if(self.ownership_pods[id] == null){
        self.ownership_pods[id] = new REALTIMEDRAFT.OwnershipPod(ownerships_j[i]);
        self.ownership_pods[id].buildTeam();
        self.ownership_pods[id].buildPlayer();
        self.element.append(self.ownership_pods[id].element);
      }
    }
  }

  // when a user 'focuses' on a different tab in the
  // browser window, sse stops and then restarts
  // connection, missing a slew of potential drafts,
  // so here we remove all current pods and replace with
  // the new init json obj sent by server
  function disposeAllPods(){
    for(var id in self.ownership_pods){
      if(self.ownership_pods.hasOwnProperty(id) && self.ownership_pods[id] != null){
        self.ownership_pods[id].dispose();
        self.ownership_pods[id] = null;
      }
    }
  }



  self.mergeOwnership = function(ownership, attrs){
    ownership.resetStyles();
    self.ownership_pods[attrs.ownership.ownership_id] = ownership;
    self.element.prepend(ownership.element);
  }


  self.coords = function(){
    var c = {};
    c["left"] = self.element.offset().left - self.element.parent().offset().left;
    c["top"] = self.element.offset().top - self.element.parent().offset().top;
    return c;
  }

};