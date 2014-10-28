REALTIMEDRAFT.DraftBuilder = function(){
  "use strict";
  var control_panel = null,
      player_panel = null,
      team_panel = null,
      ownership_panel = null,
      info_panel = null,
      element = null,
      draft_pod = null,
      startup = null;
  
  var self = this;
  self.element = $("<div class='draft-layout'>");
  self.next_team = null;
  self.draft_queue = [];

  setupAjaxDefaults();
  initialize();
  bindDefaults();
  bindFeed();

  function initialize(){
    control_panel = new REALTIMEDRAFT.ControlPanel();
    player_panel = new REALTIMEDRAFT.PlayerPanel();
    team_panel = new REALTIMEDRAFT.TeamPanel();
    ownership_panel = new REALTIMEDRAFT.OwnershipPanel(); 
    info_panel = new REALTIMEDRAFT.InfoPanel(); 
    build();
  };

  function build(){
    self.element.append(team_panel.element);
    self.element.append(control_panel.element);
    self.element.append(player_panel.element);
    self.element.append(ownership_panel.element);
    self.element.append(info_panel.element);
    $('body').append(self.element);
    self.element.hide();
    self.element.fadeIn(700);
  }



  function prepNextDraft(attrs){
    self.next_team = team_panel.selectTeamPod(attrs.next_pick);
    if(self.next_team == null){
      // alert("The Draft is complete. Please restart the draft.");
      return null;
    }
    draft_pod = new REALTIMEDRAFT.OwnershipPod();
    
    self.element.append(draft_pod.element);
    draft_pod.centerPod();
    draft_pod.element.hide();
    draft_pod.element.fadeIn(400);

    self.next_team.setAbsPos();
    team_panel.popTeamPod(attrs.next_pick);
    self.next_team.appendAtPos();
    var d_pod = draft_pod;
    self.next_team.moveToDraftPod(d_pod, {
      complete: function(){
        d_pod.mergeTeam(self.next_team);
        self.prevPickInProgress = false;
        attemptDraft();
      }
    });

    return draft_pod;
  }


  function setupAjaxDefaults(){
    $.ajaxSetup({
      accepts: {
        json: 'application/vnd.nfl_draft.v1'
      }
    });
  }


  function bindDefaults(){
    $("body").tooltip({
      delay: 200,
      selector: "[data-infotip='default']",
      container: 'body',
      trigger: "hover"
    });
  }

  function bindFeed(){
    REALTIMEDRAFT.es.addEventListener("draft.startup", function(e){
      disposeCenterPod();
      startup = JSON.parse(e.data);
      draft_pod = prepNextDraft(startup);
      self.element.append(draft_pod.element);
      draft_pod.centerPod();
    });

    REALTIMEDRAFT.es.addEventListener("draft.pub_draft_made", function(e){
      var attrs = JSON.parse(e.data);
      self.draft_queue.push(attrs);
      attemptDraft();
    });
  }

  function attemptDraft(){
    if(self.draft_queue.length != 0 && !self.prevPickInProgress){
      self.prevPickInProgress = true;
      var cur_attrs = self.draft_queue.shift();
      executeDraft(cur_attrs, {
        complete: function(){
          draft_pod = prepNextDraft(cur_attrs);
          self.element.append(draft_pod.element);
          draft_pod.centerPod();
        }
      });
    }
  }



  function executeDraft(attrs, options){
    options = options || {};
    var complete_cb = options["complete"];
    var player_pod = player_panel.selectPlayerPod(attrs.ownership);
    player_pod.setRelPos();
    player_pod.setAbsFromRel();
    player_pod.animateToTop({complete: function(){
      var the_attrs = attrs;
      player_pod.setAbsPos();
      player_panel.popPlayerPod(attrs.ownership);
      player_pod.appendAtPos();
      var d_pod = draft_pod;
      var own_panel = ownership_panel;
      player_pod.moveToDraftPod(d_pod, {
        complete: function(){
          var attrs = the_attrs;
          var p_pod = player_pod;
          var o_panel = own_panel;
          d_pod.mergePlayer(p_pod);
          d_pod.moveToOwnershipPanel(ownership_panel, {
            complete: function(){
              ownership_panel.mergeOwnership(d_pod, attrs);
              complete_cb.call();
            }
          });
        }}
      );
    }});
  };

  // can't just call dispose() on draft_pod
  // as it still has reference to the element that
  // was just merged with ownership panel,
  // but if the user switches tabs in the browser,
  // and then switches back, the center pod
  // could potentially be orphaned :(
  function disposeCenterPod(){
    draft_pod = null;
    var orphaned_center_pod = $(".draft-layout > .ownership-pod");
    orphaned_center_pod.unbind();
    orphaned_center_pod.remove();
  }
};
