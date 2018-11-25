iOS
===

OpenRemote iOS console and other OpenRemote related iOS platform and library development

Please check http://www.openremote.org/display/docs/OpenRemote+iOS+Console for more information.

The AppleDoc documentation of the client library can be found at https://openremote.github.io/iOS

Skip to content
 openremote / Documentation
You are over your private repository plan limit (4 of 0). Please upgrade your plan, make private repositories public, or remove private repositories so that you are within your plan limit.
Your private repositories have been locked until this is resolved. Thanks for understanding. You can contact support with any questions.
Code  Issues 4  Pull requests 0  Projects 0  Wiki  Pulse  Community
Samsung Smart TV
evasmolders edited this page on Jan 15, 2017 · 2 revisions
The Samsung TV Remote protocol can be used to control Samsung TV's which support the Samsung iOS remote app. Usually these include the "Smart Hub" feature and have an ethernet port.

The TV has to be turned for this to work. Also, when OpenRemote connects for the first time you have to use your TV's remote to grant access for the new "IP remote".

Starting with version 1.0.11, the Samsung TV Remote protocol is not bundled anymore with the Pro Controller distribution but needs to be separately installed. This also affects some aspects of configuration. Please take a look at the specific section below covering these aspects in detail.

##OpenRemote controller configuration

For the protocol to work, you have to specify the IP address of your TV in the controller configuration. In the moment you cannot do this via the designer which means you have to edit the file "config.properties" manually.

The file is located within the controller in the folder "webapps/controller/WEB-INF/classes".

You have to change the ip address in this section:

#-----------------------------------------------------------------------
#
# Samsung TV CONFIGURATION:
# 
# Configuration related to Samsung TV remote control protocol

##
# IP-Address of the Samsung TV to use
samsungTV.interface.ip=192.168.100.15

#
#----------------------------------------- end of Samsung TV ---------
After this is done restart the controller and design your remote.

##OpenRemote Online Designer

Now, let's create a remote in OpenRemote Designer. The Online Designer already supports the Samsung TV Remote protocol, so all you need is an account to log into it.

Our task will be to create Volume up and down buttons and a mute button.

###Create new Device In "Building Modeler", create new device (New>New Device)

Samsung Smart TV - 1

###Create commands Still in "Building Modeler", select device that was created in step 1 and click on New>New Command Specify a name and select "Samsung TV Remote" as protocol.

Samsung Smart TV - 2

Samsung TV Remote specific settings:

KeyCode - The keyCode to send to the TV
The following keyCodes are available, but maybe not all work for your TV:
KEY_0,
KEY_1,
KEY_2,
KEY_3,
KEY_4,
KEY_5,
KEY_6,
KEY_7,
KEY_8,
KEY_9,
KEY_11,
KEY_12,
KEY_3SPEED,
KEY_4_3,
KEY_16_9,
KEY_AD,
KEY_ADDDEL,
KEY_ALT_MHP,
KEY_ANGLE,
KEY_ANTENA,
KEY_ANYNET,
KEY_ANYVIEW,
KEY_APP_LIST,
KEY_ASPECT,
KEY_AUTO_ARC_ANTENNA_AIR,
KEY_AUTO_ARC_ANTENNA_CABLE,
KEY_AUTO_ARC_ANTENNA_SATELLITE,
KEY_AUTO_ARC_ANYNET_AUTO_START,
KEY_AUTO_ARC_ANYNET_MODE_OK,
KEY_AUTO_ARC_AUTOCOLOR_FAIL,
KEY_AUTO_ARC_AUTOCOLOR_SUCCESS,
KEY_AUTO_ARC_CAPTION_ENG,
KEY_AUTO_ARC_CAPTION_KOR,
KEY_AUTO_ARC_CAPTION_OFF,
KEY_AUTO_ARC_CAPTION_ON,
KEY_AUTO_ARC_C_FORCE_AGING,
KEY_AUTO_ARC_JACK_IDENT,
KEY_AUTO_ARC_LNA_OFF,
KEY_AUTO_ARC_LNA_ON,
KEY_AUTO_ARC_PIP_CH_CHANGE,
KEY_AUTO_ARC_PIP_DOUBLE,
KEY_AUTO_ARC_PIP_LARGE,
KEY_AUTO_ARC_PIP_LEFT_BOTTOM,
KEY_AUTO_ARC_PIP_LEFT_TOP,
KEY_AUTO_ARC_PIP_RIGHT_BOTTOM,
KEY_AUTO_ARC_PIP_RIGHT_TOP,
KEY_AUTO_ARC_PIP_SMALL,
KEY_AUTO_ARC_PIP_SOURCE_CHANGE,
KEY_AUTO_ARC_PIP_WIDE,
KEY_AUTO_ARC_RESET,
KEY_AUTO_ARC_USBJACK_INSPECT,
KEY_AUTO_FORMAT,
KEY_AUTO_PROGRAM,
KEY_AV1,
KEY_AV2,
KEY_AV3,
KEY_BACK_MHP,
KEY_BOOKMARK,
KEY_CALLER_ID,
KEY_CAPTION,
KEY_CATV_MODE,
KEY_CHDOWN,
KEY_CHUP,
KEY_CH_LIST,
KEY_CLEAR,
KEY_CLOCK_DISPLAY,
KEY_COMPONENT1,
KEY_COMPONENT2,
KEY_CONTENTS,
KEY_CONVERGENCE,
KEY_CONVERT_AUDIO_MAINSUB,
KEY_CUSTOM,
KEY_CYAN,
KEY_BLUE(KEY_CYAN), // Proxy for KEY_CYAN
KEY_DEVICE_CONNECT,
KEY_DISC_MENU,
KEY_DMA,
KEY_DNET,
KEY_DNIe,
KEY_DNSe,
KEY_DOOR,
KEY_DOWN,
KEY_DSS_MODE,
KEY_DTV,
KEY_DTV_LINK,
KEY_DTV_SIGNAL,
KEY_DVD_MODE,
KEY_DVI,
KEY_DVR,
KEY_DVR_MENU,
KEY_DYNAMIC,
KEY_ENTER,
KEY_ENTERTAINMENT,
KEY_ESAVING,
KEY_EXIT,
KEY_EXT1,
KEY_EXT2,
KEY_EXT3,
KEY_EXT4,
KEY_EXT5,
KEY_EXT6,
KEY_EXT7,
KEY_EXT8,
KEY_EXT9,
KEY_EXT10,
KEY_EXT11,
KEY_EXT12,
KEY_EXT13,
KEY_EXT14,
KEY_EXT15,
KEY_EXT16,
KEY_EXT17,
KEY_EXT18,
KEY_EXT19,
KEY_EXT20,
KEY_EXT21,
KEY_EXT22,
KEY_EXT23,
KEY_EXT24,
KEY_EXT25,
KEY_EXT26,
KEY_EXT27,
KEY_EXT28,
KEY_EXT29,
KEY_EXT30,
KEY_EXT31,
KEY_EXT32,
KEY_EXT33,
KEY_EXT34,
KEY_EXT35,
KEY_EXT36,
KEY_EXT37,
KEY_EXT38,
KEY_EXT39,
KEY_EXT40,
KEY_EXT41,
KEY_FACTORY,
KEY_FAVCH,
KEY_FF,
KEY_FF_,
KEY_FM_RADIO,
KEY_GAME,
KEY_GREEN,
KEY_GUIDE,
KEY_HDMI,
KEY_HDMI1,
KEY_HDMI2,
KEY_HDMI3,
KEY_HDMI4,
KEY_HELP,
KEY_HOME,
KEY_ID_INPUT,
KEY_ID_SETUP,
KEY_INFO,
KEY_INSTANT_REPLAY,
KEY_LEFT,
KEY_LINK,
KEY_LIVE,
KEY_MAGIC_BRIGHT,
KEY_MAGIC_CHANNEL,
KEY_MDC,
KEY_MENU,
KEY_MIC,
KEY_MORE,
KEY_MOVIE1,
KEY_MS,
KEY_MTS, //Dual
KEY_MUTE,
KEY_NINE_SEPERATE,
KEY_OPEN,
KEY_PANNEL_CHDOWN,
KEY_PANNEL_CHUP,
KEY_PANNEL_ENTER,
KEY_PANNEL_MENU,
KEY_PANNEL_POWER,
KEY_PANNEL_SOURCE,
KEY_PANNEL_VOLDOW,
KEY_PANNEL_VOLUP,
KEY_PANORAMA,
KEY_PAUSE,
KEY_PCMODE,
KEY_PERPECT_FOCUS,
KEY_PICTURE_SIZE,
KEY_PIP_CHDOWN,
KEY_PIP_CHUP,
KEY_PIP_ONOFF,
KEY_PIP_SCAN,
KEY_PIP_SIZE,
KEY_PIP_SWAP,
KEY_PLAY,
KEY_PLUS100,
KEY_PMODE,
KEY_POWER,
KEY_POWEROFF,
KEY_POWERON,
KEY_PRECH,
KEY_PRINT,
KEY_PROGRAM,
KEY_QUICK_REPLAY,
KEY_REC,
KEY_RED,
KEY_REPEAT,
KEY_RESERVED1,
KEY_RETURN,
KEY_REWIND,
KEY_REWIND_,
KEY_RIGHT,
KEY_RSS, // Internet
KEY_INTERNET(KEY_RSS), // Proxy for KEY_RSS
KEY_RSURF,
KEY_SCALE,
KEY_SEFFECT,
KEY_SETUP_CLOCK_TIMER,
KEY_SLEEP,
KEY_SOUND_MODE,
KEY_SOURCE,
KEY_SRS,
KEY_STANDARD,
KEY_STB_MODE,
KEY_STILL_PICTURE,
KEY_STOP,
KEY_SUB_TITLE,
KEY_SVIDEO1,
KEY_SVIDEO2,
KEY_SVIDEO3,
KEY_TOOLS,
KEY_TOPMENU,
KEY_TTX_MIX,
KEY_TTX_SUBFACE,
KEY_TURBO,
KEY_TV,
KEY_TV_MODE,
KEY_UP,
KEY_VCHIP,
KEY_VCR_MODE,
KEY_VOLDOWN,
KEY_VOLUP,
KEY_WHEEL_LEFT,
KEY_WHEEL_RIGHT,
KEY_W_LINK, // Media P
KEY_YELLOW,
KEY_ZOOM1,
KEY_ZOOM2,
KEY_ZOOM_IN,
KEY_ZOOM_MOVE,
KEY_ZOOM_OUT;

Since we are going to configure a second and third command, click on "Submit and continue". This will store our current settings, but preserver filled-in values. We can then easily update settings without the need to re-enter all the values again.

Samsung Smart TV - 3

And the last one.

Samsung Smart TV - 4

Since we are not going to add any other command, click on "Submit". We are done in the Building Modeler and have created all commands.

Samsung Smart TV - 5

###Create sensors

We don't have any sensors because the protocol is not able to read status information from the TV in the moment. The Samsung TV's itself do provide some feedback which can be read from the device but this is not implemented.

###Use commands in UI Designer

Now we switch to the UI Designer and create a panel which will be our remote. The panel will contain three buttons which are linked to our three commands.

Samsung Smart TV - 6

###Result

Here you can see the result of our work.

Samsung Smart TV - 7

Starting with version 1.0.11, the Samsung TV Remote protocol is not bundled anymore with the Pro Controller distribution but needs to be separately installed (due to the licensing terms associated with some of the code used in this implementation).

The Pro Controller is instead shipped with a "dummy" version of the protocol, that prints a warning message. To restore the full functionality requires you to replace the existing jar with the full implementation, which is done following this procedure:

download the samsungtv.jar file from here.
stop the controller
inside your Controller main folder, go to webapps/controller/WEB-INF/lib
replace the existing samsungtv.jar with the one you downloaded above
re-start the controller
The eBox disk image does not contain the Samsung protocol implementation either and also requires the above jar to be installed.

On the eBox, the controller is installed in /opt/OpenRemote-Controller. The procedure is similar to one described above, with the caveat that the file system on which the controller is installed is read-only. You must make it writable before applying the changes, this is done using the 'remountrw' command.

The IP address of the Samsung TV is not configured via the "config.properties" file anymore but directly in the Designer.

In the Designer, in the "Config for Controller" pane, there is now a "samsungtv" section. In that section, there is "samsungTV.address" property that is used to configure the address.

Do not modify the other property ("protocol.samsungTV.classname").

Samsung Smart TV - SamsungTV_Configuration

 Pages 92
UI Designer
Create New Panel
Device Templates
Control Screens and groups
User Interface Design
Graphs with EmonCMS
Graphs with RRD4J
Console Widget Behaviour
Building Modeller
Create Device
Create Command
Create Virtual Command
Create Sensor
Create Range Sensor
Create Custom Sensor
Create Switch
Create Sliders
Macros
DateTime Protocol
Alarm Protocol
Rules
Rules Examples
Scheduled Rule Examples
Advanced Rule Examples
Account Management
Invite other Users
Roles in the Designer
Export & Import Projects
Export & Import
Example Home
Controller Configuration
Controller Configuration
Controller Discovery Configuration
Controller Rule Configuration
Controller Security Configuration
Controller Z-wave Configuration
Install Controller
Install the Controller
Raspberry Pi
Synology NAS
Synchronize Controller
User Application Consoles
Download iOS and Android Console
iOS Console
Android Console
Web Console
Devices & Protocol Integration
1-Wire
AMX
Asus O!Play
Beckhoff
Belkin Wemo
Denon
DMX / SPi (Art-Net adaptor)
Domintell
DSC Security
EnOcean
ESP8266
Global Caché
HTTP/REST
HTTP/MJPEG
ICT Protege
Insteon
IRTrans
KAKU/COCO
Keene IR
KNX
Leviton HAI
LightwaveRF
Lutron
Marantz AV Receiver
MiCasa Verde Vera
Modbus
PanStamps
Philips Hue
Philips Pronto
RazBerry
Russound
Samsung Smart TV
Shell Execution
Smappee
SNMP
Sonos
TCP/IP
UDP
Velbus
X10
XBMC
XML data sources
Z-wave
Developers
Developer Guide 3.0
Clone this wiki locally

https://github.com/openremote/Documentation.wiki.git
© 2018 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
Press h to open a hovercard with more details.
