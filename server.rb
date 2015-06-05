require "sinatra/base"
require "sinatra/reloader"
require "redcarpet"
require 'sendgrid-ruby'
require "pry"

require_relative "db/connection"
require_relative "models/comment"
require_relative "models/post"
require_relative "models/user"


module App

	class Server < Sinatra::Base
	include Forum

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
    	# will this work for someone logging in from a different computer?
			url = "http://ipinfo.io/json" 
      response = RestClient.get(url)
      data = JSON.parse(response)
      @city = data["city"]
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
	    hash = {
		    :name  			=> params[:name]
		    :email 			=> params[:email]
		    :password 	=> params[:password]
		    :loc   			=> geo_tagger()
		    :rating 		=> 0
		    :post_num 	=> 0
		    :created_at => Time.now
	  	}
	  	@new_user = Forum::User.new(hash)
	    @is_user = $db.exec_params("SELECT * FROM users WHERE name = $1 AND email = $2",[@new_user.name, @new_user.email])
	    	if  @is_user.ntuples == 0
			    id = $db.exec_params("INSERT INTO users (name, email, loc, rating, password, post_num, created_at)
			      VALUES($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP) RETURNING id", [@new_user.name, @@new_user.email, @@new_user.loc, @@new_user.rating, @@new_user.password, @@new_user.post_num, @new_user.created_at])
			    @id =id.first["id"]   
			    redirect "/users/#{@id}"
			  else
			    # binding.pry
			  	@message = "That username/email is already in use"
			  	erb :homepage
			  end
    end

# Time.parse 

    get '/users/:id' do
    	# render markdown of post history
      markdown = Redcarpet::Markdown.new(renderer, extensions = {})
      # This should GET a user
      @id = (params[:id])
      # add all posts to users/:id
      @user_profile = $db.exec_params("SELECT * FROM users LEFT JOIN posts ON users.id = posts.user_id WHERE users.id = $1;" ,[@id]).first 
      @user_posts = $db.exec_params("SELECT posts.message FROM posts JOIN users on posts.user_id = users.id WHERE users.id = $1;" ,[@id]).entries
      
      binding.pry

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
# Here, the renderer variable refers to a renderer object, inheriting from Redcarpet::Render::Base. If the given object has not been instantiated, the library will do it with default arguments.

# Rendering with the Markdown object is done through Markdown#render. Unlike in the RedCloth API, the text to render is passed as an argument and not stored inside the Markdown instance, to encourage reusability. Example:

# => "<p>This is <em>bongos</em>, indeed.</p>"


	post('/new_post') do
    if logged_in?
      # This should CREATE a new post
			hash = {
				:title 			=> params[:title],
				:cat 				=> params[:cat],
				:content		=> params[:content]
				:upvotes  	=> 0,
				:downvotes 	=> 0,
				:created_at => Time.now
				:updated_at => Time.now
			}
			@new_post  = Forum::Post.new(hash)
			# binding.pry
      result = $db.exec_params("INSERT INTO posts (user_id, title, cat, upvotes, downvotes, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id", [params[:user_id]], @new_post.title, @new_post.cat, @new_post.content, @new_post.upvotes, @new_post.downvotes, @new_post.created_at, @new_post.updated_at])
      redirect "/users/#{result.first["id"]}"
      else
        status 403
        "PERMISSION DENIED"
			end
		end

	 # -------------------- COMMENTS -----------------

	 post('/new_post') do
    if logged_in?
      # This should CREATE a new post
			hash = {
				:title 			=> params[:title],
				:cat 				=> params[:cat],
				:content		=> params[:content]
				:upvotes  	=> 0,
				:downvotes 	=> 0,
				:created_at => Time.now
				:updated_at => Time.now
			}
			@new_post  = Forum::Post.new(hash)
			# binding.pry
      result = $db.exec_params("INSERT INTO posts (user_id, title, cat, upvotes, downvotes, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id", [params[:user_id]], @new_post.title, @new_post.cat, @new_post.content, @new_post.upvotes, @new_post.downvotes, @new_post.created_at, @new_post.updated_at])
      redirect "/users/#{result.first["id"]}"
      else
        status 403
        "PERMISSION DENIED"
			end
		end

			

	end #Server

end #App

# how do I seed.sql if all new data is in form of an object



