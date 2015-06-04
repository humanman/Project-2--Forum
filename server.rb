require "sinatra/base"
require "sinatra/reloader"


require_relative "db/connection"

module App

	class Server < Sinatra::Base

		configure do
      register Sinatra::Reloader
      set :sessions, true
    end

    # ----------------USERS----------------

     get('/') do
      erb :homepage
    end

    # get('/login') do
    #   erb :login
    # end

    post('/login') do
      email = params[:email]
      password = params[:password]

      query = "SELECT * FROM users WHERE email = $1 LIMIT 1"
      results = $db.exec_params(query, [email])
      user = results.first # if we don't find a matching user this is nil
      if user && user['password'] == password
        session[:user_id] = user['id'] # store the id in session to save it between requests
        redirect '/user'
      else
        @message = 'incorrect email or password'
        erb :homepage
      end
    end

    get('/user') do
      user_id = session[:user_id] # retrieve the stored user id
      if user_id
        query = "SELECT * FROM users WHERE id = $1 LIMIT 1"
        results = $db.exec_params(query, [user_id])

        @user = results.first
        erb :dashboard
      else
        redirect '/'
      end

    end

    delete ('/logout') do
      session[:user_id] = nil
      redirect '/'
    end
	 
	 # ------------------- POSTS -----------------














	 # -------------------- COMMENTS -----------------
			

	end #Server

end #App