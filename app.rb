require 'yaml'

require 'bundler'
Bundler.require


configure { set :server, :puma }

class Live < Sinatra::Base
  connections = []

  get '/' do
    erb :index
  end
end
