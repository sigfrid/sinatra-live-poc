#!/usr/bin/env ruby

require 'yaml'

require 'bundler'
Bundler.require

configure { set :server, :puma }

class Live < Sinatra::Base
  connections = []

  get '/' do
    erb :index
  end

  get '/the_stream', provides: 'text/event-stream' do
    p "in"
    stream :keep_open do |out|
    #  loop do
        out << "This is an EventSource message"
      #  sleep 1
      #end
    end


  end
end
