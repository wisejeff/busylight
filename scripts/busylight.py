import socket
import requests
from datetime import datetime
import unicornhat as uh
import threading
from time import sleep

serverUrl = ''
busyStatus = "Free"
globalRed = 0
globalGreen = 0
globalBlue = 0

#setup the unicorn hat
uh.set_layout(uh.AUTO)
uh.brightness(0.5)

#get the width and height of the hardware
width, height = uh.get_shape()

def busy_light():
    try:
        set_status("Offline")

        while True:
            #sleep for 1 second
            sleep(5)
            #fetch the status
            now = datetime.now().time()
            current_time = now.strftime("%H:%M:%S")
            print(f'Fetching Status {current_time}')
            r = requests.get(serverUrl)
            newStatus = r.text
            print(f'Status is: {newStatus}')
            #set lights based on status if status changed
            if busyStatus != newStatus:
                set_status(newStatus)                

    except Exception as e:
        print(e)

    print("Exiting")


def set_status(status):
    global busyStatus
    busyStatus = status

    print(f'Status has changed to {status}')

    if status == "Offline":
        set_lights(255,255,255,'','')
    elif status == "Free":
        set_lights(0,144,0,'','')
    elif status == "Busy":
        set_lights(252, 117, 20,'','')        
    elif status == "DoNotDisturb":
        set_lights(94,1,120,'','')                
    elif status == "Away" or status == "TemporarilyAway":
        set_lights(255,191,0,'','')
    elif status == "In a call" or status == "In a conference call":
        set_lights(179,0,0,'','')
    elif status == "In a video call":
        set_lights(94,1,120,'','')
    else:
        set_lights(255,255,255,'','')        

def set_lights(r, g, b, brightness, speed):

    if brightness != '' :
	    uh.brightness(brightness)

    for y in range(height):
	    for x in range(width):
		    uh.set_pixel(x, y, r, g, b)
    uh.show()

    if speed != '' :
        sleep(speed)
        uh.clear()
        crntT = threading.currentThread()
        while getattr(crntT, "do_run", True) :
            for y in range(height):
                for x in range(width):
                    uh.set_pixel(x, y, r, g, b)
            uh.show()
            sleep(speed)
            uh.clear()
            uh.show()
            sleep(speed)

if __name__ == "__main__":
    busy_light()
