require "sinatra/base"
require "sinatra/reloader"
require "redcarpet"
require 'sendgrid-ruby'

require_relative "db/connection"

module App

	class Server < Sinatra::Base

		configure do
      register Sinatra::Reloader
      set :sessions, true
    end

    def current_user 
      session[:user_id]
    end

    def logged_in?
      !current_user.nil?
    end

    def password_check(arg1, arg2)
    	arg1 == arg2 ? true : false
    end

    def geo_tagger
			url = "http://ipinfo.io/8.8.8.8/json"
      response = RestClient.get(url)
      data = JSON.parse(response)
      @city = "http://ipinfo.io/8.8.8.8/city"
    end

    def counter


    end

    # ----------------USERS----------------

     get('/') do
      erb :homepage
    end

    # get('/login') do
    #   erb :login
    # end

    post('/users/login') do
      email = params[:email]
      password = params[:password]

      query = "SELECT * FROM users WHERE email = $1 LIMIT 1"
      results = $db.exec_params(query, [email])
      user = results.first # if we don't find a matching user this is nil
      if user && user['password'] == password
        session[:user_id] = user['id'] # store the id in session to save it between requests
        redirect "/users/#{user['id']}"
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
        geo_tagger()
        @user = results.first
        erb :homepage
      else
        redirect '/'
      end
    end

    get '/users' do
	    # This should get all of the users (READ)
	    @users = $db.exec_params("SELECT * FROM users;") 
	    erb :users
    end

    post '/users' do
	    # This should CREATE a new user
	    @name  		= params[:name]
	    @email 		= params[:email]
	    @password = params[:password]
	    @loc   		= geo_tagger()
	    @rating 	= 0
	    @post_num = 0
	    @is_user 	= []
	    @is_user.push($db.exec_params("SELECT * FROM users WHERE name = $1 AND email = $2",[@name, @email]))

	    	if @is_user.size == 0
			    id = $db.exec_params("INSERT INTO users (name, email, loc, rating, password, post_num, created_at)
			      VALUES($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP) RETURNING id", [@name, @email, @loc, @rating, @password, @post_num])
			    redirect "/users/#{id.first["id"]}"
			  else
			  	@message = "That username/email is already in use"
			  	erb :homepage
			  end
    end


    get '/users/:id' do
      # This should GET a user
      @id = (params[:id])
      # add all posts to users/:id
      @user_profile = $db.exec_params("SELECT * FROM users JOIN posts ON users.id = posts.user_id WHERE users.id = $1;" ,[@id]).first 
      erb :user
  	end

    patch '/users/:id' do
    	"hello patch route"
      # This should UPDATE a user
    end

    delete ('/logout') do
      session[:user_id] = nil
      redirect '/'
    end
	 
	 # ------------------- POSTS ----------------------
	 # Initializes a Markdown parser
# markdown = Redcarpet::Markdown.new(renderer, extensions = {})
# Here, the renderer variable refers to a renderer object, inheriting from Redcarpet::Render::Base. If the given object has not been instantiated, the library will do it with default arguments.

# Rendering with the Markdown object is done through Markdown#render. Unlike in the RedCloth API, the text to render is passed as an argument and not stored inside the Markdown instance, to encourage reusability. Example:

# markdown.render("This is *bongos*, indeed.")
# => "<p>This is <em>bongos</em>, indeed.</p>"













	 # -------------------- COMMENTS -----------------
			

	end #Server

end #App