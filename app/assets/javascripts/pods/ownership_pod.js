REALTIMEDRAFT.OwnershipPod = function(attrs){
  "use strict";
  this.element = $("<div class='ownership-pod base-pod'>");
  var self = this;
  self.attrs = attrs;
  if(attrs != null){
    self.element.data("id", attrs.ownership_id);
  }
  // build ownership pod from player_pod and team_pod,
  // that way they can easily be seperated when
  // Draft TimeMachine is implemented

  self.buildTeam = function(){
    self.team_pod = new REALTIMEDRAFT.TeamPod(self.attrs);
    self.element.append(self.team_pod.element);
  }

  self.buildPlayer = function(){
    self.player_pod = new REALTIMEDRAFT.PlayerPod(self.attrs);
    self.element.append(self.player_pod.element);
  }

  self.mergePlayer = function(pp){
    self.player_pod = pp;
    self.player_pod.resetStyles();
    self.element.append(self.player_pod.element);
  }

  self.mergeTeam = function(tm){
    self.team_pod = tm;
    self.team_pod.resetStyles();
    self.element.append(self.team_pod.element);
  }

  self.centerPod = function(){
    self.element.css('width', '200px');
    $(window).on('resize', center_handler);
    center_handler();
  }

  var center_handler = function(){
    var dl = $(".draft-layout");
    var wind_w = dl.width();
    var wind_h = dl.height();
    var self_w = self.element.outerWidth();
    var self_h = self.element.outerHeight();
    var l = (wind_w - self_w)/2;
    var t = (wind_h - self_h)/2;

    self.element.css({
      left:l +"px",
      top:t - 50 +"px"
    });
  };

  self.coords = function(){
    return self.element.offset();
  };


  self.resetStyles = function(){
    self.element.css({
      left: "",
      top: "",
      width: ""
    });
  };

  self.moveToOwnershipPanel = function(ownership_panel, options){
    $(window).unbind("resize", center_handler);
    options = options || {};
    var complete_cb = options["complete"];
    var left = ownership_panel.coords().left;
    var top = ownership_panel.coords().top;
    self.element.animate({
      left: left + "px",
      top: top + "px"
    }, 250, complete_cb);
  };
};