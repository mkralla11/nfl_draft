REALTIMEDRAFT.ControlPanel = function(){
  "use strict";
  var self = this;
  self.draft_status = "stop";
  self.manual_active = false;
  self.element = $("<div class='control-panel'>");
  build();
  bind();


  REALTIMEDRAFT.es.addEventListener("draft.pub_start", function(e){
    self.draft_status = "start"
    self.draft_status_btn.text("Pause Draft");
    console.log(e.data + " ControlPanel");
  });

  REALTIMEDRAFT.es.addEventListener("draft.pub_pause", function(e){
    self.draft_status = "pause"
    self.draft_status_btn.text("Continue Draft");
    console.log(e.data + " ControlPanel");
  });

  REALTIMEDRAFT.es.addEventListener("draft.pub_draft_made", function(e){
    console.log(e.data + "DRAFT MADE ControlPanel");
  });


  function build(){
    self.draft_status_btn = $("<div class='draft-status-btn btn btn-primary'>Start Auto-Live Draft</div>");
    self.draft_restart_btn = $("<div class='draft-restart-btn btn btn-warning'>Restart Draft</div>");
    self.draft_rand_btn = $("<div class='draft-rand-btn btn btn-info'>Single-Random Draft</div>");
    self.draft_manual_btn =  $("<div class='draft-manual-btn btn btn-default'>Single-Manual Draft</div>");

    self.element.append(self.draft_status_btn);
    self.element.append(self.draft_restart_btn);
    self.element.append(self.draft_rand_btn);
    self.element.append(self.draft_manual_btn);
  };

  function bind(){
    bindDraftStatusBtn();
    bindRandBtn();
  };



  function bindRandBtn(){
    self.draft_rand_btn.on("click",function(){
      if(self.draft_status == "start"){
        $(this).addClass("disabled");
      }
      else{
        $.ajax({
          type: "POST",
          url: "/draft/start",
          dataType: "json",
          data: {'single': true, 'pick-type': "random"}
          // error: function(data){
          //   
          // }
        });
      }
    });
  };


  function bindDraftStatusBtn(){
    self.draft_status_btn.on("click", function(){
      if(self.draft_status == "start"){
        self.draft_status = "pause";
      }else{
        self.draft_status = "start";
      }
      $.ajax({
        type: "POST",
        url: "/draft/" + self.draft_status,
        dataType: "json",
        data: {'single': false, 'pick-type': "random"},
        error: function(data){
          var test = 1
        }
      });
    });
  };
};
