#!/usr/bin/env python

import dbus, json

bus = dbus.SessionBus()
obj = bus.get_object("com.Gwibber.Accounts", "/com/gwibber/Accounts")
accounts = dbus.Interface(obj, "com.Gwibber.Accounts")

data = {
  "authtype": "login",
  "color": "#4E9A06",
  "username": "",
  "password": "",
  "service": "twitter",
  "receive_enabled": True,
  "send_enabled": True,
}

accounts.Create(json.dumps(data))
