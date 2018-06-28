require 'yaml'

require 'bundler'
Bundler.require

get '/' do
  conn = PG::Connection.new(YAML.load(File.read("config/database.yml"))["development"])
  puts "connected"
  channels = ['notifications']

  begin
    channels.each do |channel|
      conn.async_exec "LISTEN #{channel}"
      puts "listening ..."

      loop do
        # This will block until a NOTIFY is issued on one of these two channels.
        conn.wait_for_notify do |channel, pid, payload|
          puts "Received a NOTIFY on channel #{channel}"
          puts "from PG backend #{pid}"
          puts "saying #{payload}"
        end
      end
    end
  ensure
    # Don't want the connection to still be listening once we return
    # it to the pool - could result in weird behavior for the next
    # thread to check it out.
    conn.async_exec "UNLISTEN *"
  end

  erb :index
end
