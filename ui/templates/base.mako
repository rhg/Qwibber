<%def name="map(lat, long, w=175, h=80, maptype='mobile')">
  <a href="http://maps.google.com/maps?q=${lat},${long}">
    <img src="http://maps.google.com/staticmap?zoom=12&size=${w}x${h}&maptype=${maptype}&markers=${lat},${long}" />
  </a>
</%def>

<%def name="profile_url(data)" filter="trim">
  % if services.has_key(data["service"]):
    % if "user_messages" in services[data["service"]]["features"]:
      gwibber:/user?acct=${data["account"]}&amp;name=${data["sender"]["nick"]}
    % else:
      ${data['sender']['url']}
    % endif
  % endif
</%def>

<%def name="comment(data)">
  % if "sender" in data:
    % if "name" in data["sender"]:
      <p><a href="${data["sender"]["url"]}">${data["sender"]["name"]}</a>: ${data['text']}</p>
    % endif
  % endif
</%def>

<%def name="msgclass(data, classes=['unread', 'reply', 'private'])">
  <% return " ".join(i for i in classes \
    if hasattr(data, "is_" + i) and getattr(data, "is_" + i)) %>
</%def>

<%def name="msgstyle(data)" filter="trim">
</%def>

<%def name="location(data)">
  <div class="position">
    ${self.map(data["location"]["lat"], data["location"]["lon"])}
  </div>
</%def>

<%def name="geo_position(data)">
  <div class="position">
    % if hasattr(data, "location_name"):
      <p class="location">${_("Posted from: %s" % data.location_name)}</p>
    % endif
    ${self.map(*data.geo_position)}
  </div>
</%def>

<%def name="likes(data)">
  % if isinstance(data["likes"], dict):
    % if data["likes"]["count"] > 1:
      <p class="likes">${_("%s users liked this" % data["likes"]["count"])}</p> 
    % elif data["likes"]["count"] == 1:
      <p class="likes">${_("%s user liked this" % data["likes"]["count"])}</p> 
    % endif  
  % endif  
</%def>

<%def name="comments(data)">
  <div class="comments">
    % for c in data["comments"][-3:]:
      ${self.comment(c)}
    % endfor
  </div>
</%def>

<%def name="image(data)">
  % if data.get("private", 0):
    % if "recipient" in data:
      % if data['recipient'].get("is_me", 0):
        % if "sender" in data:
          % if "image" in data["sender"]:
            <a href="${profile_url(data)}">
              <div class="imgbox" title="${data["sender"].get("nick", "")}" style="background-image: url(${data["sender"]["image"]});">
              <div class="imgbox" title="${data["recipient"].get("nick", "")}" style="margin: 25px 0px 0px 25px; width: 25px; height: 25px; background-image: url(${data["recipient"]["image"]});"></div></div>
            </a>
          % endif
        % endif
      % else:
        % if "image" in data["recipient"]:
            <a href="${profile_url(data)}">
              <div class="imgbox" title="${data["sender"].get("nick", "")}" style="background-image: url(${data["sender"]["image"]});">
              <div class="imgbox" title="${data["recipient"].get("nick", "")}" style="margin: 25px 0px 0px 25px; width: 25px; height: 25px; background-image: url(${data["recipient"]["image"]});"></div></div>
            </a>
        % endif
      % endif
    % endif
  % else:
    % if "sender" in data:
      % if "image" in data["sender"]:
        <a href="${profile_url(data)}">
          <div class="imgbox" title="${data["sender"].get("nick", "")}" style="background-image: url(${data["sender"]["image"]});"></div>
      </a>
      % endif
    % endif
  % endif
</%def>

<%def name="link(data)">
  % if "name" in data["link"]:
    % if data['link']['name']:
        <p><b><a href="${data['link']['url']}">${data['link']['name']}</a></b></p>
    % else:
        <p><b><a href="${data['link']['url']}">${_("link")}</a></b></p>
    % endif
  % endif
  % if "description" in data["link"]:
    % if data["link"]["description"]:
      <p>${data['link']['description']}</p>
    % endif
  % endif
  % if "picture" in data["link"]:
    <div class="thumbnails">
      <a href="${data['link']['url']}"><img src="${data['link']['picture']}" /></a>
    </div>
  % endif
</%def>

<%def name="video(data)">
  % if "name" in data["video"]:
      <p><b><a href="${data['video']['source']}">${data['video']['name']}</a></b></p>
  % endif
  % if "description" in data["video"]:
    % if data["video"]["description"]:
      <p>${data['video']['description']}</p>
    % endif
  % endif
  % if "picture" in data["video"]:
    <div class="thumbnails">
      <a href="${data['video']['source']}"><img src="${data['video']['picture']}" /></a>
    </div>
  % endif
</%def>


<%def name="photo(data)">
  % if "name" in data["photo"]:
    % if data['photo']['name']:
       <p><b>${data['photo']['name']}</b></p>
    % endif
  % endif
  <div class="thumbnails">
    <a href="${data['photo']['url']}"><img src="${data['photo']['picture']}" /></a>
  </div>
</%def>

<%def name="images(data)">
  <div class="thumbnails">
    % for i in data["images"]:
      <a href="${i['url']}"><img src="${i.get('src', 0) or i.get('src', 0)}" /></a>
    % endfor
  </div>
</%def>

<%def name="dupes(data)">
  % if "dupes" in data and len(data['dupes']) > 0:
    <div class="dupes">
      % for d in data['dupes']:
        ${self.message(d, -1)}
      % endfor
    </div>
  % endif
</%def>

<%def name="buttons(data)">
  <div class="buttonitem">
    <a href="gwibber:/menu?msg=${data['id']}"><img width="16px" src="${util.icon('system-run')}" title=${_("Menu")} /></a> 
  </div>
  <div class="buttonitem">
    % if data.get("private", 0):
      % if "recipient" in data:
        <a href="gwibber:/private?msg=${data['id']}"><img width="16px" src="${util.icon('mail-reply-sender')}" title=${_("Reply")} /></a> 
      % endif
    % else:
      % if services.has_key(data["service"]):
        % if "reply" in services[data["service"]]["features"]:
          <a href="gwibber:/reply?msg=${data['id']}"><img width="16px" src="${util.icon('mail-reply-sender')}" title=${_("Reply")} /></a>
        % endif
      % endif
    % endif
  </div>
</%def>

<%def name="extended_text(data)">
  <p class="text">${data.extended_text}</p>
</%def>

<%def name="fold(data, ops=['extended_text', 'photo', 'images', 'video', 'link', 'comments', 'location', 'likes'])">
  <div class="fold">
    % for o in ops:
      % if data.get(o, 0):
        ${getattr(self, o)(data)}
      % endif
    % endfor
  </div>
</%def>
  
<%def name="timestring(data)" filter="trim">
  <a href="gwibber:/read?msg=${data['id']}">${data['time_string']}</a>
  % if data.get("source", 0):
    <a>${_("from")} ${data["source"]}</a>
  % endif
  % if data.get("reply", {}).get("nick", 0):
    % if data.get("reply", {}).get("url", 0):
      <a href="${data['reply'].get('url', '#')}">${_("in reply to")} ${data['reply']['nick']}</a>
    % endif
  % endif
</%def>

<%def name="sender(data)" filter="trim">
  % if "sender" in data:
    % if preferences["show_fullname"]:
      % if data.get("private", 0):
        % if "recipient" in data:
          % if data['recipient'].get("is_me", 0):
            ${data['sender'].get("name", 0) or data["sender"].get("nick", "")}
          % else:
           ${data['recipient'].get("name", 0) or data["recipient"].get("nick", "")}
          % endif
        % else:
          ${data['sender'].get("name", 0) or data["sender"].get("nick", "")}
        % endif
      % else:
        ${data['sender'].get("name", 0) or data["sender"].get("nick", "")}
      % endif
    % else:
      % if data.get("private", 0):
        % if "recipient" in data:
          % if data['recipient'].get("is_me", 0):
            ${data['sender'].get("nick", 0) or data["sender"].get("name", "")}
          % else:
            ${data['recipient'].get("nick", 0) or data["recipient"].get("name", "")}
          % endif
        % else:
          ${data['sender'].get("nick", 0) or data["sender"].get("name", "")}
        % endif
      % else:
        ${data['sender'].get("nick", 0) or data["sender"].get("name", "")}
      % endif
    % endif
  % endif
</%def>

<%def name="title(data)">
  <span class="title">${data['title'] if "title" in data else sender(data)}</span>
</%def>

<%def name="sigil(data)">
  <span class="sigil">
    <img src="${util.get_service_icon(data['service'], 16)}" />
  % if data.get("sigil", 0):
    <img src="${data['sigil']}" />
  % endif

  % if data.get("private", 0):
    % if "recipient" in data:
      % if data['recipient'].get("is_me", 0):
        <img src="${resources.get_ui_asset('icons/streams/16x16/private.png')}" />
      % else:
        <img src="${resources.get_ui_asset('icons/streams/16x16/sent.png')}" />
      % endif
    % else:
      <img src="${resources.get_ui_asset('icons/streams/16x16/private.png')}" />
    % endif
  % endif
  </span>
</%def>

<%def name="content(data)">
  <p class="content">
    ${sigil(data)}   
    ${title(data)}
    <span class="time"> (${timestring(data)})</span><br />
  % if data.get("rtl", False):
    <span class="text rtl">${data.get('content', '')}</span>
  % else:
    <span class="text" id="text-${data['id']}">${data.get('content', '')}</span>
  % endif
  </p>
</%def>

<%def name="sidebar(data)">
  % if "sender" in data:
    % if "image" in data["sender"]:
      ${self.image(data)}
    % endif
  % endif
</%def>

<%def name="messagebox(data)">
  <div id="${data["id"]}" style="${self.msgstyle(data)}" class="message ${self.msgclass(data)}">
    ${caller.body()}
  </div>
</%def>

<%def name="user_header_message(data)">
  <%call expr="messagebox(data)">
    <center>
      <p class="content">
        <span class="title">${data.sender}</span><br />
        % if hasattr(data, "sender_followers_count"):
          <span class="text">${_("%s followers" % data.sender_followers_count)}</span><br />
          <span class="text">${data.sender_location}</span><br />
        % endif
        <span class="text"><a href="${data.external_profile_url}">${data.external_profile_url}</a></span>
      </p>
    </center>
  </%call>
</%def>

<%def name="toggledupe(data)">
  % if "dupes" in data and len(data["dupes"]) > 0:
    <div class="buttonitem toggledupe"><img src="${util.icon('list-add')}" /></div>
  % endif
</%def>

<%def name="listlink(data)">
  % if "sender" in data:
    gwibber:/list?acct=${data['account']}&user=${data['sender']['nick']}&id=${data['key']}&name=${data['name']}
  % endif
</%def>

<%def name="list(data, cnt)">
  <div id="msg-${cnt}" class="basemsg">
    <%call expr="messagebox(data)">
      <table cellspacing="0" cellpadding="0">
        <tr>
          <td>
            ${self.sidebar(data)}
          </td>
          <td width="100%">
            ${title(data)} / <span class="text"><a href="${listlink(data)}">${data['name']}</a></span>
            % if data.get("full", 0):
            <p><span class="text"><a href="${listlink(data)}">${data["full"]}</a></p>
            % endif
            % if data["text"]:
              <p><span class="text">${data["text"]}</span></p>
            % endif
          </td>
          <td class="buttons"></td>
        </tr>
      </table>
    </%call>
  </div>
</%def>

<%def name="message(data, cnt)">
  <div id="msg-${cnt}" class="basemsg">
    <%call expr="messagebox(data)">
      <table cellspacing="0" cellpadding="0">
        <tr>
          <td>
            ${self.sidebar(data)}
          </td>
          <td width="100%">
            ${self.content(data)}
            ${self.fold(data)}
          </td>
          <td class="buttons">
            ${toggledupe(data)}
            <div class="hidden">
            ${self.buttons(data)}
            </div>
          </td>
        </tr>
      </table>
      
      ${self.dupes(data)}
    </%call>
  </div>
</%def>

<%def name="messages(data)">
  <script>document.body.style.overflow = 'hidden'</script>
  <div class="header">
  </div>
  <div class="messages">
    % for count, m in enumerate(data):
      % if m.get("kind", 0) == "list":
        ${self.list(m, count)}
      % elif not m["is_dupe"]:
        ${self.message(m, count)}
      % endif
    % endfor
  </div>
</%def>

<%def name="accounts_list(accounts)">
  <table class="accounts">
    <thead><tr><td colspan="100%">${_("Your Accounts")}</td></tr></thead>
    % for a in accounts:
      <tr>
        <td>${a["username"]}</td>
        <td>
          <img src="${util.get_service_icon(a['service'], 16)}" />
          ${protocols[a["service"]]["name"]}
        </td>
        <td>
          <a href="gwibber:/account?id=${a['id']}"><img src="${util.icon('gtk-edit')}" /></a>
          <a href="gwibber:/account?id=${a['id']}&action=delete"><img src="${util.icon('gtk-delete')}" /></a>
        </td>
      </tr>
    % endfor
  </table>
</%def>

<%def name="account_creation(accounts)">
  <div class="content_box account_creation">
    <div class="header">${_("Create New Account")}</div>
    % for p in ["twitter", "identica", "facebook", "friendfeed"]:
      <div class="block">
        <a href="gwibber:/account?id=${p}&action=create"><img src="${util.get_ui_asset('icons/32x32/%s.png' % p)}" /></a>
        <br />${protocols[p]["name"]}
      </div>
    % endfor
  </div>
</%def>

<%def name="latest_messages(messages)">
  <div class="content_box">
    <div class="header">${_("Latest Replies")}</div>
    <div class="box_content">
      <hr />
      % for m in messages:
        <p>
          <b>${m.sender}</b> <small>(${m.time_string})</small><br />
          ${m.html_string}
        </p>
        <hr />
      % endfor
    </div>
  </div>
</%def>

<%def name="errors(data)">
  % for e in data:
    <div class="content_box">
      <div class="header">
        <img style="float: left; padding-right: 5px;" src="${util.icon('gtk-dialog-warning', use_theme=False)}" />
        ${e['error']}
        <div class="toggledupe"><img src="${util.icon('list-add')}" /></div>
      </div>
      <div class="box_content">
        <code>${e['op']['opname']}</code> failed with <code>${e['type']}</code> on ${e['op']['service']} ${e['time_string']}
        <div class="dupes">
          <pre style="font-size: small">
            ${e["traceback"]}
          </pre>
        </div>
      </div>
    </div>
    <br />
  % endfor
</%def>


