# MeetingRoomDisplay
simple display to show the status of a physical conference room

features:

* connect to Exchange 201x trough EWS
* display the current free / busy information for a conference room
* display upcoming meetings with number of participants and the meeting owner
* tested with amazon fire tab and and the app "kiosk browser"

SETUP for Docker:
set Enviroment variables

* "EWS_USER" = e.g. "password"
* "EWS_PASS" = e.g. "service-user"
* "EWS_ENDPOINT" = e.g. "https://exchange.company.com/ews/Exchange.asmx"
* "EWS_DOMAIN" = e.g. "@company.com"
* "DEFAULTROOM" = e.g. "Meetingroom1" // mailbox address of the default meetingroom minus domain address

expose port 9393 to desired external port

setup (manual install):

* add URL to EWS in credentials file
* add credentials of a service user which has read/write to the conference room mailboxes
* add your default mail domain
* (hack) add default room in main.ruby

require:
* require 'viewpoint'
* require 'pp'
* require 'time'
* require 'rubygems'
* require 'sinatra'

default port "9393"

http://ip:port/room/confroom1 (room address "confroom1@domain"
