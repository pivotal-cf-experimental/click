require 'sinatra'
require 'rack/logger'
require 'sequel'
require 'sqlite3'

require 'click'
require 'click/database'
require 'click/database/writer'

db = Sequel.sqlite('/tmp/click_demo.sqlite')

Sequel::Model.db = db

db.create_table?(:visits) do
  primary_key :id
  String :ip_address
  Time :timestamp
end

class Visit < Sequel::Model
end

Thread.abort_on_exception = true

Thread.new do
  begin
    clicker = nil
    Click::Database.with_database('sqlite:///tmp/click_demo_memory.sqlite') do |click_db|
      writer = Click::Database::Writer.new(click_db)
      clicker = Click::Clicker.new
      clicker.add_observer(writer)
    end

    loop do
      clicker.click!
      puts 'Click!'
      sleep 10
    end
  rescue => e
    puts "Exception in Click thread: #{e}"
    raise
  end
end

get '/' do
  Visit.create(ip_address: request.ip, timestamp: Time.now)

<<HTML
<html><body>
  <h1>Click demo app</h1>
  <br/>
  Visited #{Visit.count} time(s) by #{Visit.group_by(:ip_address).count} IP address(es).
</body></html>
HTML
end

$garbage = []
get '/make_objects/:count' do |count|
  $garbage.concat(Array.new(count.to_i) { Object.new })
  "I made #{count} object(s) just for you :)"
end
