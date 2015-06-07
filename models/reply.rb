module Forum

	class Reply

		def initialize(args = {})
			@user_id    = args[:user_id]
			@post_id		= args[:post_id]
			@comment_id	= args[:comment_id]
			@message		= args[:message]
			@loc				= args[:loc]
			# @upvotes 		= args[:upvotes]
			# @downvotes	= args[:downvotes]
			@created_at = args[:created_at]
			@updated_at	= args[:updated_at]
		end

		attr_accessor :user_id, :post_id, :comment_id, :message, :loc, :created_at, :updated_at

	end
end
