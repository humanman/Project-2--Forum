require "sinatra/base"
require "sinatra/reloader"


require_relative "db/connection"

module App

	class Server < Sinatra::Base

		configure do
      register Sinatra::Reloader
      set :sessions, true
    end
	
			
		end

	end

end