var REALTIMEDRAFT = REALTIMEDRAFT || {};
REALTIMEDRAFT.TeamPod = function(attrs){
  "use strict";
  var self = this;
  self.element = $("<div class='team-pod base-pod'>");
  self.attrs = attrs;
  self.element.data("id", attrs.team_id);
  var abs_coords = {}


  self.name_e = $("<div class='team-name'>" + attrs.team_name + "</div>");
  self.division_e = $("<div class='team-division description'>" + attrs.division_name + "</div>");
  self.pick_num_e = $("<div title='Pick' data-placement='right' data-infotip='default' class='info-tip team-pick-num'>" + attrs.pick + "</div>");
  self.round_num_e = $("<div title='Round' data-placement='left' data-infotip='default' class='info-tip team-round-num'>" + attrs.round + "</div>");

  self.element.append(self.name_e);
  self.element.append(self.division_e);
  self.element.append(self.pick_num_e);
  self.element.append(self.round_num_e);



  self.setAbsPos = function(){
    abs_coords = self.element.offset();
  };

  self.resetStyles = function(){
    self.element.css({
      left: "",
      top: "",
      width: "",
      'z-index': "",
      position: ""
    });
  }


  self.appendAtPos = function(){
    if(abs_coords.left != null && abs_coords.top != null){
      self.element.css({
        left: abs_coords.left +"px",
        top: abs_coords.top + "px",
        position: "absolute"
      });
      $("body").append(self.element);
    };
  };

  self.moveToDraftPod = function(draft_pod, options){
    options = options || {};
    var complete_cb = options["complete"];
    var left = draft_pod.coords().left;
    var top = draft_pod.coords().top;
    self.element.animate({
      left: left + "px",
      top: top + "px"
    }, calculateSpeed(250), complete_cb);
  };

  self.dispose = function(){
    self.element.unbind();
    self.element.remove();
  }


  function calculateSpeed(s){
    return (s / 2) * REALTIMEDRAFT.speed;
  }
};