require "sinatra/base"
require "sinatra/reloader"
require "redcarpet"
require "sendgrid-ruby"
require "gon"
require "pry"

require_relative "db/connection"
require_relative "models/comment"
require_relative "models/post"
require_relative "models/user"
require_relative "models/reply"


module App

	class Server < Sinatra::Base
		include Forum
		enable :sessions

		configure do
      register Sinatra::Reloader
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

    def geo_tagger(ip)
			url = "http://ipinfo.io/#{ip}/json" 
      response = RestClient.get(url)
      data = JSON.parse(response)
      @city = data["city"]
      	if @city == nil
      		@city = "Earth"
      	end
      @city
    end

     get('/') do
     	@all_posts = $db.exec_params("SELECT * FROM posts JOIN users on posts.user_id = users.id ORDER BY upvotes DESC")
      erb :homepage
     end
    # ----------------USERS----------------


    # get('/login') do
    #   erb :login
    # end

    post('/users/login') do

    	@all_posts = $db.exec("SELECT * FROM posts ORDER BY upvotes DESC;")
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
        geo_tagger(reqest.ip)
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
	    ip = request.ip
	    hash = {
		    :name  			=> params[:name],
		    :email 			=> params[:email],
		    :password 	=> params[:password],
		    :loc   			=> geo_tagger(ip),
		    :rating 		=> 0,
		    :post_num 	=> 0
	  	}
	  	@new_user = Forum::User.new(hash)
	    @is_user = $db.exec_params("SELECT * FROM users WHERE name = $1 AND email = $2",[@new_user.name, @new_user.email])
	    	if  @is_user.ntuples == 0
			    result = $db.exec_params("INSERT INTO users (name, email, loc, rating, password, post_num, created_at)
			      VALUES($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP) RETURNING id", [@new_user.name, @new_user.email, @new_user.loc, @new_user.rating, @new_user.password, @new_user.post_num])
			    @id = result.first["id"] 
			    session[:user_id] = @id  
			    # binding.pry
			    redirect "/users/#{@id}"
			  else
			  	@message = "That username/email is already in use"
			  	erb :homepage
			  end
    end

# Time.parse 

    get '/users/:id' do
    	# render markdown of post history
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      # This should GET a user
      @id = (params[:id])
      # add all posts to users/:id
      @user_profile = $db.exec_params("SELECT * FROM users LEFT JOIN posts ON users.id = posts.user_id WHERE users.id = $1;" ,[@id]).first 
      @user_posts = $db.exec_params("SELECT * FROM posts LEFT JOIN users on posts.user_id = users.id WHERE users.id = $1;" ,[@id]).entries
      
      # binding.pry

      erb :user
  	end

    patch '/users/:id' do
    	"hello patch route"
      # This should UPDATE a user
    end

    delete'/logout' do
      session[:user_id] = nil
      redirect "/"
    end
	 
	 # ------------------- POSTS ----------------------

	post'/new_post' do
    if logged_in?
      # This should CREATE a new post

			hash = {
				:user_id    => current_user.to_i,
				:title 			=> params[:title],
				:cat 				=> params[:cat],
				:content		=> params[:content],
				:upvotes  	=> 0,
				:downvotes 	=> 0,
				:loc 				=> geo_tagger(request.ip)
			}

			@new_post  = Forum::Post.new(hash)
      # binding.pry
			
      result = $db.exec_params("INSERT INTO posts (user_id, title, cat, content, upvotes, downvotes, loc, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id",[@new_post.user_id, @new_post.title, @new_post.cat, @new_post.content, @new_post.upvotes, @new_post.downvotes, @new_post.loc])
      # submit buttong takes user to page of new post
      redirect "/posts/#{result.first["id"]}"
    else
			# binding.pry
	    status 403
	    "PERMISSION DENIED"
		end
	end

	get'/posts/:id' do
		@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
		@id = (params[:id])
		# when user clicks on post title from feed, they should be taken to a page for that post with comments below.
		@current_post = $db.exec("SELECT * FROM posts JOIN users on posts.user_id = users.id WHERE posts.id = #{@id}").first
		@comments_feed = $db.exec_params("SELECT * FROM comments RIGHT JOIN posts on comments.post_id = posts.id WHERE comments.post_id = $1 ORDER BY comments.upvotes DESC;" ,[@id]).entries
		@reply_feed = $db.exec_params("SELECT * FROM comments LEFT JOIN replies on comments.id = replies.comment_id WHERE comments.post_id = $1 ORDER BY replies.created_at DESC;" ,[@id]).entries
		erb :post
		# binding.pry
	end	

	patch'/upvote_post' do
		@id = params["post_id"]
		@upvote = $db.exec_params("UPDATE posts
		SET upvotes = upvotes + 1 WHERE id = $1",[@id])
		# binding.pry
		redirect "/posts/#{@id}"
	end

	patch'/downvote_post' do
		@id = (params["post_id"])
		@downvote = $db.exec_params("UPDATE posts
		SET downvotes = downvotes + 1 WHERE id = $1",[@id])
		# binding.pry
		redirect "/posts/#{@id}"
	end

	 # -------------------- COMMENTS -----------------


	 post'/new_comment' do
    if logged_in?
      # This should CREATE a new post
			hash = {
				:user_id 		=> current_user.to_i,
				:post_id    => params[:post_id].to_i,
				:message 		=> params[:message],
				:loc				=> geo_tagger(request.ip),
				:upvotes  	=> 0,
				:downvotes 	=> 0,
			}
			@new_comment  = Forum::Comment.new(hash)
			# binding.pry
      result = $db.exec_params("INSERT INTO comments (user_id, post_id, message, loc, upvotes, downvotes, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id", [@new_comment.user_id, @new_comment.post_id, @new_comment.message, @new_comment.loc, @new_comment.upvotes, @new_comment.downvotes])
     	# binding.pry
      redirect "/posts/#{params[:post_id]}"
      else
        status 403
        "PERMISSION DENIED"
			end
		end

		post'/reply' do
	    if logged_in?
	      # This should CREATE a new post
				hash = {
					:user_id    => current_user.to_i,
					:post_id		=> params[:post_id].to_i,
					:comment_id	=> params[:comment_id].to_i,
					:message 		=> params[:message],
					:loc				=> geo_tagger(request.ip)
				}

				@new_reply = Forum::Reply.new(hash)
				# binding.pry
	      result = $db.exec_params("INSERT INTO replies (user_id, post_id, comment_id, message, loc, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id, message, post_id", [@new_reply.user_id, @new_reply.post_id, @new_reply.comment_id, @new_reply.message, @new_reply.loc])
	     	# binding.pry
	      redirect "/posts/#{result.first['post_id']}"
      else
        status 403
        "PERMISSION DENIED"
			end
			redirect "/posts/#{@id}"
		end

		patch'/upvote_comment' do
			@id = params["post_id"]
			@comment_id = params["comment_id"]
			@upvote = $db.exec_params("UPDATE comments
			SET upvotes = upvotes + 1 WHERE id = $1",[@comment_id])
			# binding.pry
			redirect "/posts/#{@id}"
		end

		patch'/downvote_comment' do
			@id = (params["post_id"])
			@comment_id = params["comment_id"]
			@downvote = $db.exec_params("UPDATE comments
			SET downvotes = downvotes + 1 WHERE id = $1",[@comment_id])
			# binding.pry
			redirect "/posts/#{@id}"
		end


			

	end #Server

end #App

# how do I seed.sql if all new data is in form of an object.
# Will erb squid work differently now that I have objects set up?
# will my geo_tagger actually work?
# Time.now or CURRENT_TIMESTAMP?? Ruby or SQL??

