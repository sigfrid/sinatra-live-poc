require 'yaml'

require 'bundler'
Bundler.require

Faye::WebSocket.load_adapter('thin')

get '/' do
  if Faye::EventSource.eventsource?(request.env)
    es = Faye::EventSource.new(env)

    conn = PG::Connection.new(YAML.load(File.read("config/database.yml"))["development"])
    channels = ['notifications']

    begin
      channels.each do |channel|
        conn.async_exec "LISTEN #{channel}"

        loop do
          # This will block until a NOTIFY is issued on one of these two channels.
          conn.wait_for_notify do |channel, pid, payload|
            es.send(eval(payload)[:location])
            puts "SENT ... \n"
          end
        end
      end
    ensure
      # Don't want the connection to still be listening once we return
      # it to the pool - could result in weird behavior for the next
      # thread to check it out.
      conn.async_exec "UNLISTEN *"
      puts "UNLISTEN"
    end

    es.rack_response
  else
    erb :index
  end
end
