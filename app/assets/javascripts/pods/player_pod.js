var REALTIMEDRAFT = REALTIMEDRAFT || {};
REALTIMEDRAFT.PlayerPod = function(attrs){
  "use strict";
  this.element = $("<div class='player-pod base-pod'>");
  var self = this;
  self.attrs = attrs;
  this.element.data("id", attrs.player_id);
  var abs_coords = {},
      rel_coords = {};


  self.name_e = $("<div class='player-name'>" + attrs.player_name + "</div>");
  self.position_e = $("<div class='player-position description'>" + attrs.position_name + "</div>");

  self.element.append(self.name_e);
  self.element.append(self.position_e);

  self.setAbsPos = function(){
    abs_coords = self.element.offset();
  };

  self.setRelPos = function(){
    rel_coords['left'] = self.element.offset().left - self.element.parent().offset().left;
    rel_coords['top']= self.element.offset().top - self.element.parent().offset().top;
  }

  self.setAbsFromRel = function(){
    self.element.css({
      left: rel_coords.left +"px",
      top: rel_coords.top +"px",
      position: "absolute",
      'z-index': 2
    })
  }

  self.resetStyles = function(){
    self.element.css({
      left: "",
      top: "",
      width: "",
      'z-index': "",
      position: ""
    });
  }

  self.animateToTop = function(options){
    options = options || {};
    var complete_cb = options["complete"];
    self.element.animate({
      top:"0px"
    }, calculateSpeed(700), complete_cb);
  }


  self.appendAtPos = function(){
    if(abs_coords.left != null && abs_coords.top != null){
      self.element.css({
        left: abs_coords.left +"px",
        top: abs_coords.top + "px"
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