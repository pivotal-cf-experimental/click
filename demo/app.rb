require 'sinatra'
require 'rack/logger'
require 'sequel'
require 'sqlite3'

require 'click'
require 'click/database'

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
    Click.clicker_with_database('Click demo app', 'sqlite:///tmp/click_demo_memory.sqlite') do |clicker|
      loop do
        clicker.click!
        puts 'Click!'
        sleep 10
      end
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
