REALTIMEDRAFT.StatusPod = function(){
  "use strict";
  var self = this;
  self.attrs = null;


  self.element = $("<div class='status-pod'>");
  build();

  function build(attrs){
    self.pick_num_e = $("<div title='Pick' class='status-pick-num'></div>");
    self.round_num_e = $("<div title='Round' class='status-round-num'></div>");
    self.element.append(self.pick_num_e);
    self.element.append(self.round_num_e);
  }


  self.update = function(attrs){
    self.attrs = attrs;
    if(attrs != null){
      self.pick_num_e.html("<span class='less'>Pick </span> " + self.attrs.next_pick.pick);
      self.round_num_e.html("<span class='less'>Round </span> " + self.attrs.next_pick.round);
    }
    else{
      self.pick_num_e.text("Draft Finished");
      self.round_num_e.text("");
    }
  };
};