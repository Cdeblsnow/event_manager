require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'


def clean_zipcode(zipcode)

  zipcode.to_s.rjust(5, '0')[0..4]
end


def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials

  rescue 
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end


def valid_phone_numbers(phone_number)

  phone_number.gsub!(/[^0-9A-Za-z]/, '')

  if phone_number.length == 10
    phone_number

  elsif phone_number.length == 11 && phone_number.chr == "1"
   phone_number = phone_number[1..-1]
   phone_number

  else
   phone_number = "invalid phone number"
  end
end


def peak_registration_hours(hours)
  hour_hash = Hash.new(0)

  hours.each do |hour|
    hour_hash[hour] += 1
  end

  peak_hours = []

  peak = hour_hash.map {|key,value| value}.max

  hour_hash.each do |hour,registered_users|
    peak_hours.push(hour) if registered_users == peak
  end
  
  peak_hours
end

def peak_registration_days(day)
  day_hash = Hash.new(0)

  day.each do |day_of_week|
    day_hash[day_of_week] += 1
  end

  peak_days = []

  peak = day_hash.map {|key,value| value}.max

  day_hash.each do |day,registered_users|
    peak_days.push(day) if registered_users == peak
  end

  peak_days
end

#def save_thank_you_letter(id,form_letter)

 # Dir.mkdir('output') unless Dir.exist?('output')

  #filename = "output/thanks_#{id}.html"

  #File.open(filename, 'w') do |file|
  #  file.puts form_letter
  #end
#end


puts 'Event Manager initialized!'

contents = CSV.open(
  'event_attendees.csv', 
  headers: true,
  header_converters: :symbol
  ) 

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

time = []
day = []
contents.each do |row|
  id = row[0]
  
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  phone_number = valid_phone_numbers(row[:homephone]) 

  date_time = Time.strptime(row[:regdate], "%m/%d/%y %k:%M")
  time.push(date_time.hour)
  day.push(date_time.wday)
  
  
  

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  
  
  #save_thank_you_letter(id,form_letter)
  
end


peak_days = peak_registration_days(day)
peak_hours = peak_registration_hours(time)
puts "Most people registred at #{peak_hours} hrs"
puts "Most people registred the days ##{peak_days} of the week"