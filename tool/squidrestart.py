#!/usr/bin/python3
import requests
import time
from subprocess import call

proxies = {
  "http": "proxy.host:port",
  "https": "proxy.host:port",
}
while True:
  try:
    r = requests.get("http://google.com/", proxies=proxies)
    if r.status_code!=200:
      raise "Proxy not responding"
    else:
      print("Proxy seems working")
  except:
    print("Restarting proxy")
    call(["systemctl", "restart", "squid"])
  time.sleep(60)
