module Forum

	class Comment

		def initialize(args = {})
			@user_id    = args[:user_id]
			@post_id		= args[:post_id]
			@message		= args[:message]
			@loc				= args[:loc]
			@upvotes 		= args[:upvotes]
			@downvotes	= args[:downvotes]
			@created_at = args[:created_at]
			@updated_at	= args[:updated_at]
		end

		attr_accessor :user_id, :post_id, :message, :loc, :upvotes, :downvotes, :created_at, :updated_at


	end

end