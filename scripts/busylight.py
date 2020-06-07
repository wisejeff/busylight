import socket
import requests
from datetime import datetime
import unicornhat as uh
import threading
from time import sleep

frequency = 5
apiKey = ''
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
            #sleep for 5 second
            sleep(frequency)
            #fetch the status
            now = datetime.now().time()
            current_time = now.strftime("%H:%M:%S")
            print(f'Fetching Status {current_time}')
            r = requests.get(f'{serverUrl}/status/{apiKey}')
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
        set_dnd_lights(179,0,0,'','')                
    elif status == "Away" or status == "TemporarilyAway":
        set_lights(255,191,0,'','')
    elif status == "In a call" or status == "In a conference call":
        set_lights(179,0,0,'','')
    elif status == "In a video call":
        set_lights(94,1,120,'','')
    else:
        set_lights(255,255,255,'','')        

def set_dnd_lights(r, g, b, brightness, speed):
    uh.clear()
    
    # if brightness != '':
	#     uh.brightness(brightness)

    # for y in range(height):
    #     for x in range(width):
    #         if y == height -1 and x < height:
    #             uh.set_pixel(x, y, r, g, b)
    #             uh.set_pixel(x, y - x, 255, 255, 255)
    #         else:
    #             uh.set_pixel(x, y, r, g, b)
    
    uh.set_pixel(0, 0, r, g, b)
    uh.set_pixel(1, 1, r, g, b)
    uh.set_pixel(2, 2, r, g, b)
    uh.set_pixel(3, 3, r, g, b)
    uh.set_pixel(4, 0, r, g, b)
    uh.set_pixel(5, 1, r, g, b)
    uh.set_pixel(6, 2, r, g, b)
    uh.set_pixel(7, 3, r, g, b)

    uh.set_pixel(0, 3, r, g, b)
    uh.set_pixel(1, 2, r, g, b)
    uh.set_pixel(2, 1, r, g, b)
    uh.set_pixel(3, 0, r, g, b)
    uh.set_pixel(4, 3, r, g, b)
    uh.set_pixel(5, 2, r, g, b)
    uh.set_pixel(6, 1, r, g, b)
    uh.set_pixel(7, 0, r, g, b)

    uh.show()

    # if speed != '' :
    #     sleep(speed)
    #     uh.clear()
    #     crntT = threading.currentThread()
    #     while getattr(crntT, "do_run", True) :
    #         for y in range(height):
    #             for x in range(width):
    #                 uh.set_pixel(x, y, r, g, b)
    #         uh.show()
    #         sleep(speed)
    #         uh.clear()
    #         uh.show()
    #         sleep(speed)

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
