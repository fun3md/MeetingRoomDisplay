require 'viewpoint'
#require 'viewpoint/logging/config'
require 'pp'
require 'time'
require 'rubygems'
require 'sinatra'

include Viewpoint::EWS
load './credentials.rb'



set :protection, :except => :frame_options
set :bind, '0.0.0.0'
set :port, 9393

get '/' do	
	outbuffer=retrieveews(ENV['DEFAULTROOM'],'template2punkt0.html' ) # default room
		outbuffer
end

get '/room/:roomname' do
	outbuffer=retrieveews(params[:roomname],'template2punkt0.html')
	outbuffer
end

get '/status/:roomname' do
	outbuffer=retrieveews(params[:roomname],'templatestatus.html')
	outbuffer
end

get '/room/:roomname/create/:minutes' do
	
	createMeeting(params[:minutes].to_i, params[:roomname] + Domain)
	outbuffer=retrieveews(params[:roomname],'template2punkt0.html')
	outbuffer
end

get '/create/:minutes' do
	createMeeting(params[:minutes].to_i, "Saal_Elbblick" + Domain)
	outbuffer=retrieveews()
	outbuffer
end

def connectews()
	cli = Viewpoint::EWSClient.new Endpoint, User, Pass, http_opts: {ssl_verify_mode: 0}
	# => to get all available time zones
	#pp cli.ews.get_time_zones(full=false,ids=nil)
	cli.set_time_zone("W. Europe Standard Time")
	return cli
end

def getcalendarews(usermail,cli)
	pp usermail
	return cli.get_folder :calendar, opts = {act_as: usermail}
end

def createMeeting(minutes,usermail)
	cli=connectews()

	calendar=getcalendarews usermail, cli

	calendar.create_item(:subject => 'spontanes Meeting', :start => Time.now, :end => Time.now+minutes*60)
end

def getmeetingstring(cal, subjectstring)
	return (cal.start.strftime("%H:%M")+'-'+cal.end.strftime("%H:%M")+' / '+cal.start.strftime("%F")+' :<br> '+cal.organizer.name+' ('+cal.required_attendees.count.to_s+' Teilnehmer)<br>'+subjectstring)
end

def humanize secs
  [[60, :Minuten], [24, :Stunden], [1000, :Tage]].map{ |count, name|
    if secs > 0
      secs, n = secs.divmod(count)
      "#{n.to_i} #{name}"
    end
  }.compact.reverse.join(' ')
end

 
def retrieveews(roomname, template)
	buf = File.read(template)
	buf.gsub! '%room%', 'room/'+roomname

	cli=connectews()

	folder = getcalendarews roomname+Domain, cli
	
	sd = Date.today()-1
	ed = Date.today()+10 #look 5 days ahead

	#calendaritems= folder.items_between sd, ed

	#calendaritems=folder.todays_items
	
	# => DEBUG
	#puts "#{sd.rfc3339()}"
	#puts "#{ed.rfc3339()}"
	
	pp folder.folder_id
	
	calendaritems = folder.find_items({:folder_id => folder.folder_id,  :calendar_view => {:start_date => sd.rfc3339(), :end_date => ed.rfc3339()}})
	pp calendaritems.count

	calendaritems.each do |event|
		  puts "#{event.start} - #{event.end}\t #{event.subject}"
	end
	
	calendaritems=calendaritems.sort_by { |calendaritems| calendaritems.start }
	calendaritems.delete_if {|calendaritems|calendaritems.end < DateTime.now()}

	timenow=DateTime.now()
	index=0
	roomfree=false
	calendaritems.each do |cal|
		# => DEBUG
		pp index
		pp cal.recurring?
		pp cal.subject
		pp cal.start.rfc3339()
		pp cal.end.rfc3339()
		pp timenow.rfc3339()
		pp cal.start.to_time.to_i - timenow.to_time.to_i
		
		# => DEBUG

		if !cal.subject.nil? && index==0
			if  timenow < cal.end &&  timenow < cal.start
					buf.sub! '%starttime%', 'FREI'
	                buf.sub! '%startdate%', ''
	                buf.sub! '%endtime%', cal.start.strftime("%H:%M")
	                #buf.sub! '%enddate%', ''
	                buf.sub! '%persons%', "0"
	                buf.sub! '%organizer%', '-'
	                buf.sub! '%subject%', 'Raum ist frei'
	                buf.sub! '%showroom%', 'hidden'
	                buf.sub! '%showattendees%', 'hidden'
	                buf.sub! '%duration%', 'noch<br>'+humanize((cal.start.to_time.to_i - timenow.to_time.to_i) / 60)
	            if ((cal.start.to_time.to_i - timenow.to_time.to_i)/60) < 59
 	                buf.gsub! 'lightgreen', 'gold'
					buf.gsub! 'green', 'goldenrod'
					buf.gsub! 'darkgreen', 'darkgoldenrod'
				end

				if cal.recurring? == true
              		subjectbuf= 'Besprechung (Serientermin)'
          	 	else
                	subjectbuf= 'Besprechung'
           		end

				buf.sub! '%nextmeeting%', (cal.start.strftime("%H:%M")+'-'+cal.end.strftime("%H:%M")+' / '+cal.start.strftime("%F")+' :<br> '+cal.organizer.name+' ('+cal.required_attendees.count.to_s+' Teilnehmer)<br>'+subjectbuf)
				roomfree=true
			else
				buf.gsub! 'lightgreen', 'tomato'
				buf.gsub! 'green', 'red'
				buf.gsub! 'darkgreen', 'darkred'
				buf.sub! '%starttime%', 'BELEGT'
				buf.sub! '%endtime%', cal.end.strftime("%H:%M")
				buf.sub! '%persons%', cal.required_attendees.count.to_s
				buf.sub! '%duration%', 'noch<br>'+humanize((cal.end.to_time.to_i - timenow.to_time.to_i) / 60)
			end
			
			if cal.recurring? == true
				buf.sub! '%subject%', 'Besprechung (Serientermin)'
			else
				buf.sub! '%subject%', 'Besprechung'
			end
			
			buf.sub! '%startdate%', cal.start.strftime("%F")
			buf.sub! '%enddate%', cal.end.strftime("%F")
			buf.sub! '%organizer%', cal.organizer.name
			cal.required_attendees.each do |names|
				buf=buf
			end
		end

		if index==1 

			if cal.recurring? == true
                subjectbuf= 'Besprechung (Serientermin)'
            else
                subjectbuf= 'Besprechung'
            end

			buf.sub! '%nextmeeting%', (cal.start.strftime("%H:%M")+'-'+cal.end.strftime("%H:%M")+' / '+cal.start.strftime("%F")+' :<br> '+cal.organizer.name+' ('+cal.required_attendees.count.to_s+' Teilnehmer)<br>'+subjectbuf)
		
			if roomfree==true
				if cal.recurring? == true
        	                        subjectbuf= 'Besprechung (Serientermin)'
	                        else
                	                subjectbuf= 'Besprechung'
                        	end

				buf.sub! '%nextmeeting2%', (cal.start.strftime("%H:%M")+'-'+cal.end.strftime("%H:%M")+' / '+cal.start.strftime("%F")+' :<br> '+cal.organizer.name+' ('+cal.required_attendees.count.to_s+' Teilnehmer)<br>'+subjectbuf)
			end

		end

		if index==2
			if cal.recurring? == true
                                subjectbuf= 'Besprechung (Serientermin)'
                        else
                                subjectbuf='Besprechung'
                        end

			buf.sub! '%nextmeeting2%', (cal.start.strftime("%H:%M")+'-'+cal.end.strftime("%H:%M")+' / '+cal.start.strftime("%F")+' :<br> '+cal.organizer.name+' ('+cal.required_attendees.count.to_s+' Teilnehmer)<br>'+subjectbuf)
		end
		index=index+1
	end

	buf.sub! '%nextmeeting%', ''
	buf.sub! '%nextmeeting2%',''
	buf.sub! '%starttime%','FREI'
	buf.sub! '%endtime%',''
	buf.sub! '%startdate%',''
	buf.sub! '%enddate%',''
	buf.sub! '%subject%',''
	buf.sub! '%organizer%',''
	buf.sub! '%subject%',''
	buf.sub! '%persons%','0'
	buf.sub! '%organizer%','-'
	
	buf.sub! '%duration%', ''
	buf.sub! '%lastupdate%', DateTime.now().strftime("%F/%H:%M:%S")
	buf.gsub! '%room%',''
	return buf
end
