from gwibber.microblog import network, util
from gwibber.microblog.util import log, resources
import json, htmllib, re
from gettext import lgettext as _
log.logger.name = "Foursquare"

PROTOCOL_INFO = {
  "name": "Foursquare",
  "version": "1.0",
  
  "config": [
    "private:password",
    "receive_enabled",
    "username",
    "color",
  ],

  "authtype": "none",
  "color": "#990099",

  "features": [
    "receive",
  ],

  "default_streams": [
    "receive",
  ],
}

URL_PREFIX = "https://api.foursquare.com/v1"

class Client:
  def __init__(self, acct):
    self.account = acct

  def _message(self, data):

    m = {}; 
    m["mid"] = str(data["id"])
    m["service"] = "foursquare"
    m["account"] = self.account["id"]
    m["time"] = util.parsetime(data["created"])

    shouttext = ""
    text = ""
    if data.has_key("venue"):
        if data.has_key("shout"):
            shouttext += data["shout"] + "<br/><br/>"
            text += data["shout"] + "\n"
        if data["venue"].has_key("id"):
	    m["url"] = "http://foursquare.com/venue/%s" % data["venue"]["id"]
        else:
            m["url"] = "http://foursquare.com"

        if data["venue"].has_key("primarycategory"):
            img = "<table><tr><td><img src='%s'/></td><td>" % data["venue"]["primarycategory"]["iconurl"]
        else:
            img = "<table><tr><td><img src='http://foursquare.com/img/categories/none.png'/></td><td>"
        shouttext += img + "Checked in at <a href='" + m["url"] + "'>" + data["venue"]["name"] + "</a>"
	text += "Checked in at " + data["venue"]["name"]
	if data["venue"].has_key("address"):
	    shouttext += ", " + data["venue"]["address"]
	    text += ", " + data["venue"]["address"]
	if data["venue"].has_key("crossstreet"):
	    shouttext += " and " + data["venue"]["crossstreet"]
	    text += " and " + data["venue"]["crossstreet"]
	if data["venue"].has_key("city"):
	    shouttext += ", " + data["venue"]["city"]
	    text += ", " + data["venue"]["city"]
	if data["venue"].has_key("state"):
	    shouttext += ", " + data["venue"]["state"]
	    text += ", " + data["venue"]["state"]
    else:
        if data.has_key("shout"):
            shouttext += data["shout"] + "<br/><br/>"
            text += data["shout"] + "\n"
        else:
            text= "Checked in off the grid"
            shouttext= "<table><tr><td><img src='http://foursquare.com/img/categories/question.png'/></td><td>Checked in off the grid"

    m["text"] = text
    m["content"] = shouttext + "</td></tr></table>"
    m["html"] = shouttext + "</td></tr></table>"

    m["sender"] = {}
    m["sender"]["id"] = data["user"]["id"]
    m["sender"]["image"] = data["user"]["photo"]
    m["sender"]["url"] = "http://foursquare.com/user/-%s" % data["user"]["id"]
    if data["user"]["friendstatus"] == "self": m["sender"]["is_me"] = True
    fullname = ""
    if data["user"].has_key("firstname"):
        fullname += data["user"]["firstname"] + " "
    if data["user"].has_key("lastname"):
        fullname += data["user"]["lastname"]

    m["sender"]["name"] = fullname
    m["sender"]["nick"] = fullname
        
    m["source"] = "<a href='http://foursquare.com/'>Foursquare</a>"

    return m

  def _check_error(self, data):
    if isinstance(data, dict) and "checkins" in data:
      return True
    else:
      log.logger.error("Foursquare error %s", data)
      return False

  def _get(self, path, parse="message", post=False, single=False, **args):
    url = "/".join((URL_PREFIX, path))

    data = network.Download(url, util.compact(args) or None, post,
        self.account["username"], self.account["password"]).get_json()

    resources.dump(self.account["service"], self.account["id"], data)

    if not self._check_error(data):
      return []

    checkins = data["checkins"]
    if single: return [getattr(self, "_%s" % parse)(checkins)]
    if parse: return [getattr(self, "_%s" % parse)(m) for m in checkins]
    else: return []

  def __call__(self, opname, **args):
    return getattr(self, opname)(**args)

  def receive(self):
    return self._get("checkins.json")

