#MeetingRoomDisplay
simple display to show the status of a physical conference room

features:

*connect to Exchange 201x trough EWS
*display the current free / busy information for a conference room
*display upcoming meetings with number of participants and the meeting owner
*tested with amazon fire tab and and the app "kiosk browser"

setup:

*add URL to EWS in credentials file
*add credentials of a service user which has read/write to the conference room mailboxes
*add your default mail domain
*(hack) add default room in main.ruby
