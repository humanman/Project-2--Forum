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

	end





end