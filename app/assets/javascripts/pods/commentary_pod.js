REALTIMEDRAFT.CommentaryPod = function(){
  "use strict";
  var self = this;
  self.element = $("<div class='commentary-pod'>");
  self.element_inner = $("<div class='commentary-pod-inner'>");
  self.element.append(self.element_inner);

  var html = [];
  var rptc_arr = buildPrevTeamCommentary();
  buildMessageDispatcher();
  bindAjaxErrors();


  REALTIMEDRAFT.es.addEventListener("draft.pub_paused", function(e){
    html.push("<span class='notice'>The draft has been paused!</span>");
  });

  REALTIMEDRAFT.es.addEventListener("draft.pub_draft_end", function(e){
    html.push("<span class='success'>The draft has finished!</span>");
  });

  self.update = function(attrs){
    if(attrs != null && attrs.next_pick != null){
      prevTeamHtml(attrs);
      randomPrevTeamCommentary(attrs);
      nextTeamHtml(attrs);
    }
    else{
      draftFinished();
    }
  }

  function draftFinished(){
    html.push("<span class='green'>Draft Complete</span>")
  }

  function prevTeamHtml(attrs){
    if(attrs.ownership != null){
      html.push("The <span class='team-name'>" +  attrs.ownership.team_name + "</span> just drafted <span class='player-name'>" + attrs.ownership.player_name + "</span>");
    }
  }

  function nextTeamHtml(attrs){
    html.push("The next team to draft is the <span class='team-name'>" +  attrs.next_pick.team_name +"</span>");
  }

  function randomPrevTeamCommentary(attrs){
    if(attrs.ownership != null){
      html.push(rptc_arr[Math.floor(Math.random()*rptc_arr.length)]);
    }
  }


  function buildMessageDispatcher(){
    setInterval(function(){
      var text = html.shift();
      if(text != null){
        var commentary = wrap(text);
        self.element_inner.append(commentary);
        self.element.scrollTo('100%');
      }
    }, 200);
  }

  function buildPrevTeamCommentary(){
    return [
     "Rick, I'm not sure if that was the best choice for that team...",
     "That was definitely a great pick!",
     "Maybe that pick should have been a little more thought out, Bob.",
     "Well, Rick, that was definitely the player I would have chosen from the remaining pool.",
     "Bob, this draft is really heating up!",
     "A few more picks and that team will be set up for an excellent season, Bob.",
     "This is one of the best set of players I've ever seen in a draft, Rick.",
     "I'm so excited to see who the next team picks, Bob.",
     "Rick, I'm going to grab a drink, I'll be right back.",
     "Bob, I love my job. Talking sports all day with you is a dream."
    ];
  }

  function wrap(text, options){
    if(text != null){
      options = options || {};
      var style_class = options.style_class || "";
      return "<p class='"+ style_class + "'>" + text + "</p>";
    }
  }

  function bindAjaxErrors(){
    $(document).ajaxError(function(e, jqxhr, settings, thrownError){
      var resp = JSON.parse(jqxhr.responseText);
      var text = wrap(resp.notice, {style_class: "notice"}) || wrap(JSON.parse(resp.error), {style_class: "error"});
      html.push(text);
    });
  }
};