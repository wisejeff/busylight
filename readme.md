# DIY Raspberry PI Skype status light

## Goals

* Multi-colored light to reflect the real time status of Skype for business.
* Should be automatic


## Architecture
There are three components that make the Skype Status Light function.  1) The BusyServer 2) The BusyLight and 3) The LyncReader.  The LyncReader monitors the skyp status and sends the status to the BusyServer.  The BusyLight monitors the BusyServer and changes the color of the light when the status changes.

![alt text](https://github.com/wisejeff/busylight/blob/master/Busylight-Arc.png "Architecture")

### BusyServer
The BusyServer is responsible for persisting the status and is the service that enables the BusyLight to know what the skype status is.  Each busy light is issued a unique API key that will tie the LyncReader to the right light.

BusyServer is an ASP.Net Core web application hosted on Azure.

### BusyLight
The BusyLight is the Raspberry Pi Client.  It is responsible for monitoring the status from the BusyServer and when the status changes, it will change the light color appropriately.

The BusyLight client is a simple python script that will send a request to the BusyServer every five seconds to get the status.  The script is setup as a systemd service on the Raspberry Pi and will start automatically when the Pi is turned on.

### LyncReader
The LyncReader is a .Net application that monitors the skype status via the Microsoft Lync 2016 SDK.  When the Skype status changes, it broadcasts an event that the LyncReader detects.  The LyncReader then sends the status to the BusyServer.

The LyncReader runs in the windows system tray and the icon will change color according the the Skype status.  You can "override" the Skype status with Right-click options:

* Available
* Busy
* Away
* Offline
* In a video call
* Refresh


The "In a video call" status is not a standard Skype status.  Unfortunately, Skype does not differentiate between a video call and an audio call.  In order to tell the BusyLight you are in a video call, you need to use the right-click menu item.

Refresh - It is possible for the BusyServer to get out of sync if the LyncReader fails to send the skype status.  The resend the status, use the Refresh menu item.


## Hardware needed

* Raspberry Pi Zero W and some sort of power
* Pimoroni Unicorn pHAT
* pHAT Diffuser
* 3 Pogo-a-go-go Solderless GPIO Pogo pins
* 8 GB Micro SD


## Required Software

* An SSH application such as Putty for Windows or Terminal for macOS
* DietPI OS for Raspberry PI
* Python3 for running the busylight service.

## Putting it all together
### Connecting the pHAT and the Pi
1. Attach the pHAT to the Pi using the nylon bolts, spacers and nuts provided.  See the picture below.

![alt text](https://github.com/wisejeff/busylight/blob/master/busy3.png "Raspberry Pi Zero with Unicorn pHAT")

2. Make sure that the GPIO pins are in the correct location.  See the photo and/or the pinout link.  Pins should be in position 2 for power, 6 for Ground and 12 for Data
3. After the SD card has been formatted and the DietPi image burned, then insert the SD card into the slot.
4. The lights are bright so I recommend setting the diffuser on top over the LEDs for now.

### Installing the OS
1. Format the SD card using SD Card Formatter for windows or a digital camera will also work.  https://www.sdcard.org/downloads/formatter/
2. Download the DietPi image https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Buster.7z
3. Unzip/extract the DietPi.7z image (ideally your desktop)
4. Download and install Etcher https://etcher.io/
5. Run Etcher (may need to run as administrator)
6. Select the DietPi.img file
7. Select the drive of your SD card
8. Click Flash.

### Pre-Configuration
1. Go to My Computer... select the SD card
2. Locate the file called dietpi.txt and open it with notepad
3. Set AUTO_SETUP_TIMEZONE=America/New_York
4. Set AUTO_SETUP_KEYBOARD_LAYOUT=us
5. Set AUTO_SETUP_NET_WIFI_ENABLED=1
6. Set AUTO_SETUP_SSH_SERVER_INDEX=-2
7. Set CONFIG_WIFI_COUNTRY_CODE=US
8. Save and close dietpi.txt
9. Open dietpi-wifi.txt and open it with notepad
10. Change aWIFI_SSID[0]='MySSID' and aWIFI_KEY[0]='MyWifiKey'
11. Save changes

## Time to turn on your device

For this step, you may need a micro HDMI cable to see the console as the device is booting up. (if you are accessing your device via monitor and keyboard, then plug those in now.  Otherwise, follow the steps for connecting via SSH)

1. Insert the SD card
2. Plug your devices powersource in
3. Wait for DietPi to complete some initial setup steps. (approximately 60 seconds)
4. Obtain your IP address either from the console or from your router.  Your current active IP address will show up on the login banner in the console.
5. Once completed, the login screen will appear. 

### Steps if connecting via SSH

1. Using Putty, Enter the IP Address of the Pi in the host field and click connect
2. When prompted to enter a username, enter "root"
3. When prompted to enter a password, enter "dietpi"
4. On first login, DietPi will automatically update.
5. You will be prompted to change the software install password and the root password.
6. Once the update completes, press enter to reboot the system.  You can log back in again to resume setup.

### Create a new sudo user

1. After login as root, enter the following command in the terminal.

``` bash
> adduser busybody    
```
2. Follow the prompts to complete
3. Add the user to the sudoers group

``` bash
> usermod -aG sudo busybody
```

### Install Python3 and Unicorn pHAT libraries

The unicornhat.sh script will install all necessary software required for the Pi to communicate to the pHAT

1. Switch user to busybody

```
> su -l busybody
```
2. Run script to install python and unicorn phat libs

``` bash
> sudo curl https://raw.githubusercontent.com/wisejeff/busylight/master/scripts/unicornhat.sh | bash
```

3. When prompted to install Python2, choose no.
4. When prompted to install Python3, choose yes.
5. When prompted, choose a full install
6. When prompted about aduio, choose no.
7. When prompted to reboot, choose yes.

### Install the busylight components

Create a directory for the busy light scripts...

``` bash
> mkdir busylight
> cd busylight
```

Run the script to install the busylight service

``` bash
> sudo curl https://raw.githubusercontent.com/wisejeff/busylight/master/scripts/install.sh | bash -s -u "https://busyserver.azurewebsites.net"
```

The light should come on and default to white (Offline)

The script will generate an API key for you.  You will need this to set up the LyncReader later.  Look for the message in the console for "Setting the API Key to ..."

Note: At this time, running the install script again will generate a new APIKEY.  If you need to run the script again, add the -k <YOURAPIKEY> option to the command above replacing '<YOURAPIKEY>' with the API key that the script generated the first time.

You can test the light by executing the following curl command.  Replace '<YOURAPIKEY>' with the API key generated by the script.

``` bash
> curl --location --request POST 'https://busyserver.azurewebsites.net/status/<YOURAPIKEY>' \
--header 'Content-Type: application/json' \
--data-raw '"Free"'
```
The response should be "Free" and after five seconds, the light should turn green.

## Install the LyncReader
1. Copy the LyncReader.zip file https://github.com/wisejeff/lyncreader/raw/master/LyncReader.zip to a location on your PC.
2. Extract the Lyncreader.zip
3. Open the LyncReader.exe.config file in a text editor.
4. Set the value of the ApiKey setting to your API key.
5. run the LyncReader.exe by double-clicking.

### Configure LyncReader to run at startup
1. Right-click on LyncReader.exe
2. Click "Create Shortcut"
3. Copy the shortcut to C:\Users\<USER>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup where <USER> is your windows user name.

## Case and frame for light
I used the PiBow Zero https://shop.pimoroni.com/products/pibow-zero-w case but I'm not sure I like it.  I only ended up using part of the case because it blocks access to the SD card.

I had some issues getting everything together in a case and on a frame to hang on the wall.  None of the parts I ordered came with bolts and spacers the right size to attach the case, Pi, pHAT and diffusr together.  Either the bolt was too short or the diameter was too large.

I used some scrap cherry wood for the frame.  The size was 5"x5" which turned out to be just the right size for a picture frame hanger, the Pi and a battery.  I ended up cutting a smaller hole in my frame just the right size for the lights (2" x 1").  To make the whole, I first measured and drew the 2"x1" rectangle on the board being careful to center it.  I then drilled a 1/2" hole in each corner.  Finally, I used my jigsaw to cut the rest of the rectangle out.

![alt text](https://github.com/wisejeff/busylight/blob/master/framed-light-front.png "Framed Light Front")

I left the Pi and pHAT attached as explained in the Putting it together section above.  Then I used two 1.5" x 3mm screws on opposite corners of the PiBow case to attach the diffuser, case and Pi to the back of the frame.  This sandwhiches the Pi/pHat between the case and the diffuser.  The diffuser ends up offset to one side but that is not noticible on the other side of the frame.  I then attached a frame hangar to the back and use 3M Command velcro to attach a small 2600 mAh rechargable battery to the beneath the Pi.  This gives my busylight about 10 hrs of charge.  As long as I remember to charge it overnight, I can move it anywhere in the house.

![alt text](https://github.com/wisejeff/busylight/blob/master/framed-light-back.png "Framed Light Back")

I will probably replace the case later with a 3d printed case specifically designed for this use case.  You can follow my instructions above or make your own, what ever works for you.



## Issues
Sometimes proxy server can be an issue.
A possible work-around is to add an entry to your windows hosts file:
Open the hosts file on your computer. (C:\Windows\System32\drivers\etc\hosts)
Add the following line to the end of the file:
```
137.135.91.176 busyserver.azurewebsites.net
```

## Roadmap
* Add configuration file separate from busylight.py script
* Add ability to configure light colors and brightness
* Add custom statuses to LyncReader
* Add flashing to busylight


## References
https://github.com/pimoroni/unicorn-hat
https://pinout.xyz/pinout/unicorn_phat

