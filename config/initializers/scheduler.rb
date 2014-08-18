require 'rufus-scheduler'
puts "herere"

scheduler = Rufus::Scheduler.new

scheduler.cron '* * * * *' do
  puts 'Hello... Rufus'
end
