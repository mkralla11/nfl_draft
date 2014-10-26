REALTIMEDRAFT.OwnershipPanel = function(){
  "use strict";
  var self = this;
  this.element = $("<div class='ownership-panel base-panel'>");
  this.ownership_pods = {};
  var ownership_keys = [];
  bindListeners();



  function bindListeners(){
    REALTIMEDRAFT.es.addEventListener("draft.ownership_panel_init", function(e){
      var ownerships_j = JSON.parse(e.data);
      for(var i = 0; i < ownerships_j.length; i++){
        var id = ownerships_j[i].ownership_id
        if(self.ownership_pods[id] == null){
          ownership_keys.push(id);
          self.ownership_pods[id] = new REALTIMEDRAFT.OwnershipPod(ownerships_j[i]);
          self.ownership_pods[id].buildTeam();
          self.ownership_pods[id].buildPlayer();
          self.element.append(self.ownership_pods[id].element);
        }
      }
    })

    REALTIMEDRAFT.es.addEventListener("draft.pub_draft_made", function(e){
      console.log(e.data + " OwnershipPanel");
    });
  }

  self.mergeOwnership = function(ownership){
    ownership.resetStyles();
    self.element.prepend(ownership.element);
  }


  self.coords = function(){
    var c = {};
    c["left"] = self.element.offset().left - self.element.parent().offset().left;
    c["top"] = self.element.offset().top - self.element.parent().offset().top;
    return c;
  }

};