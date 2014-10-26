REALTIMEDRAFT.InfoPanel = function(){
  "use strict";
  var self = this;
  self.element = $("<div class='info-panel'>");
  build();
  bind();

  function build(){
    self.status_pod = new REALTIMEDRAFT.StatusPod();
    self.commentary_pod = new REALTIMEDRAFT.CommentaryPod();
    self.element.append(self.status_pod.element);
    self.element.append(self.commentary_pod.element);
  }

  function bind(){
    REALTIMEDRAFT.es.addEventListener("draft.info_panel_update", function(e){
      var info_j = JSON.parse(e.data);
      self.status_pod.update(info_j);
      self.commentary_pod.update(info_j);
    });
  }

};
