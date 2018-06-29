require 'yaml'

require 'bundler'
Bundler.require



get '/' do
  erb :index
end

get '/the_stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    loop do
      out << "This is an EventSource message"
      sleep 1
    end
  end
end
