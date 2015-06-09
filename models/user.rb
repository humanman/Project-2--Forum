module Forum

	class User

		def initialize(args = {})
			@name 			= args[:name]
			@email 			= args[:email]
			@loc 				= args[:loc]
			@rating			= args[:rating]
			@password 	= args[:password]
			@post_num		= args[:post_num]
			@created_at = args[:created_at]

		end

		attr_accessor :name, :email, :loc, :rating, :password, :post_num, :created_at




		 hash = {
		    :name  			=> params[:name],
		    :email 			=> params[:email],
		    :password 	=> params[:password],
		    :loc   			=> geo_tagger(ip),
		    :rating 		=> 0,
		    :post_num 	=> 0
	  	}
	  	def self.is_user? -
	  	# this validates user - this is from server.rb
	  	 @is_user = $db.exec_params("SELECT * FROM users WHERE name = $1 AND email = $2",[@new_user.name, @new_user.email])
	    # password_check(params[:password1], params[:password2])
	    	if  @is_user.ntuples == 0  
	    		# && password_check
			    result = $db.exec_params("INSERT INTO users (name, email, loc, rating, password, post_num, created_at)
			      VALUES($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP) RETURNING id", [@new_user.name, @new_user.email, @new_user.loc, @new_user.rating, @new_user.password, @new_user.post_num])
			    @id = result.first["id"] 
			    session[:user_id] = @id  
			    # binding.pry
			    redirect "/users/#{@id}"
			  else
			  	@message = "That username/email is already in use"
			  	@front_page = $db.exec("SELECT * FROM posts ORDER BY upvotes DESC;")
			  	@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
			  	erb :homepage
				
				def self.save 
					query db and insert new user data



	end








end