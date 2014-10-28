REALTIMEDRAFT.ControlPanel = function(){
  "use strict";
  var self = this;
  self.draft_state = "stop";
  self.manual_active = false;
  self.element = $("<div class='control-panel'>");
  var attrs = null;
  build();


  REALTIMEDRAFT.es.addEventListener("draft.pub_live_start", function(e){
    self.draft_state = "start";
    updateAllBtns();
  });

  REALTIMEDRAFT.es.addEventListener("draft.pub_start", function(e){
    self.draft_state = "start";
    updateAllBtns();
  });

  REALTIMEDRAFT.es.addEventListener("draft.pub_pause", function(e){
    self.draft_state = "pause";
    updateAllBtns();
  });

  REALTIMEDRAFT.es.addEventListener("draft.pub_draft_made", function(e){
    // console.log(e.data + "DRAFT MADE ControlPanel");
  });
  
   REALTIMEDRAFT.es.addEventListener("draft.pub_update_speed", function(e){
    REALTIMEDRAFT.speed = JSON.parse(e.data).speed;
    pubUpdateSpeed();
  }); 


  function build(){
    REALTIMEDRAFT.es.addEventListener("draft.control_panel_init", function(e){
      attrs = JSON.parse(e.data);
      self.draft_state = attrs.draft_state || "stop";
      REALTIMEDRAFT.speed = attrs.speed || 2.0;

      if(self.draft_state_btn == null){
        buildSpeedDisplay();
        buildSpeedSlider();
        buildSpeedWrapper();
        buildStateBtn();
        buildRestartBtn();
        buildRandBtn();
        buildManualBtn();
      }
      else{
        updateAllBtns();
        pubUpdateSpeed();
      }
    });
  };


  function updateAllBtns(){
    updateStateBtn();
    updateRestartBtn();
    updateRandBtn();
    updateManualBtn();
  }

  /*
  *
  * State Btn Functions
  *
  */

  function buildStateBtn(){
    self.draft_state_btn = $("<div class='draft-status-btn btn btn-primary'></div>");
    updateStateBtn();
    bindDraftStateBtn();
    self.element.append(self.draft_state_btn);
  }

  function updateStateBtn(){
    if(self.draft_state == "start"){
      self.draft_state_btn.text("Pause Live Draft");
    }
    else if(self.draft_state == "stop"){
      self.draft_state_btn.text("Start Live Draft");
    }
    else{
      self.draft_state_btn.text("Continue Live Draft");
    }
  }


  function bindDraftStateBtn(){
    self.draft_state_btn.on("click", function(){
      var targ = oppositeOfState();
      $.ajax({
        type: "POST",
        url: "/draft/" + targ,
        dataType: "json",
        data: {'single': false, 'pick-type': "random"}
      });
    });
  };

  function oppositeOfState(){
    if(self.draft_state == "start"){
      return "pause";
    }
    else{
      return "start";
    }
  }

  /*
  *
  * Restart Btn Functions
  *
  */

  function buildRestartBtn(){
    self.draft_restart_btn = $("<div class='draft-restart-btn btn btn-warning'>Restart Draft</div>");
    updateRestartBtn();
    bindRestartBtn();
    self.element.append(self.draft_restart_btn);
  }


  function updateRestartBtn(){
    if(self.draft_state == "start"){
      self.draft_restart_btn.addClass("disabled");
    }
    else{
      self.draft_restart_btn.removeClass("disabled");
    }
  }

  function bindRestartBtn(){
    self.draft_restart_btn.on("click",function(){
      $.ajax({
        type: "POST",
        url: "/draft/restart",
        dataType: "json",
        data: {}
      });
    });
  };

  /*
  *
  * Rand Btn Functions
  *
  */

  function buildRandBtn(){
    self.draft_rand_btn = $("<div class='draft-rand-btn btn btn-info'>Single Random Draft</div>");
    updateRandBtn();
    bindRandBtn();
    self.element.append(self.draft_rand_btn);
  }


  function updateRandBtn(){
    if(self.draft_state == "start"){
      self.draft_rand_btn.addClass("disabled");
    }
    else{
      self.draft_rand_btn.removeClass("disabled");
    }
  }

  function bindRandBtn(){
    self.draft_rand_btn.on("click",function(){
      $.ajax({
        type: "POST",
        url: "/draft/start",
        dataType: "json",
        data: {'single': true, 'pick-type': "random"}
      });
    });
  };


  /*
  *
  * Manual Btn Functions
  *
  */

  function buildManualBtn(){
    self.draft_manual_btn =  $("<div title='Not yet implemented.' data-infotip='default' data-placement='right' class='draft-manual-btn btn btn-default'>Single Manual Draft</div>");
    updateManualBtn();
    bindManualBtn();
    self.element.append(self.draft_manual_btn);
  }


  function updateManualBtn(options){
    options = options || {};
    if(self.draft_state == "start"){
      self.draft_manual_btn.addClass("disabled");
      self.draft_manual_btn.removeClass("active");
    }
    else{
      self.draft_manual_btn.removeClass("disabled");
    }
  }

  function bindManualBtn(){

  };


  /*
  *
  * Speed Input Functions
  *
  */
  function buildSpeedDisplay(){
    self.speed_display_outer = $("<div class='speed-display-outer'></div>");
    self.speed_display_outer.append("<div class='speed-label'>Speed:</div>");
    self.speed_display = $("<div class='speed-display'>");
    self.speed_display.append(REALTIMEDRAFT.speed);
    self.speed_display_outer.append(self.speed_display);
    self.speed_display_outer.append("<div class='unit-label'>sec</div>");
  }


  /*
  *
  * Speed Slider Functions
  *
  */

  function buildSpeedSlider(){
    self.speed_slider = $("<div class='speed-slider'>");
    self.speed_slider.slider({
      min: 0.7,
      max: 4.1,
      step: 0.1,
      value: REALTIMEDRAFT.speed,
      animate: "fast",
      stop: updateSpeed,
      slide: displaySpeed
    });
  }

  function updateSpeed(event, ui){
    REALTIMEDRAFT.speed = ui.value;
    displaySpeed(event, ui);

    $.ajax({
      type: "POST",
      url: "/draft/update_speed",
      dataType: "json",
      data: {'speed': REALTIMEDRAFT.speed}
    });
  }

  function displaySpeed(event, ui){
    self.speed_display.text(ui.value);
  }

  function pubUpdateSpeed(){
    self.speed_slider.slider( "value", REALTIMEDRAFT.speed);
    self.speed_display.text(REALTIMEDRAFT.speed);
  }


  function buildSpeedWrapper(){
    self.speed_wrapper = $("<div class='container-fluid speed-wrapper'><div class='row'><div class='left col-md-3'></div><div class='right col-md-9'></div></div></div>");
    self.speed_wrapper.find('.left').append(self.speed_display_outer);
    self.speed_wrapper.find('.right').append(self.speed_slider);
    self.element.append(self.speed_wrapper);
  }
};
