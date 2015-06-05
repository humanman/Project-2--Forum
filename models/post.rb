module Forum
	
	class Post

			def initialize(args = {})
				@user_id 		= args[:user_id]
				@title 			= args[:title]
				@cat				= args[:cat]
				@content		= args[:content]
				@upvotes 		= args[:upvotes]
				@downvotes	= args[:downvotes]
				@created_at = args[:created_at]
				@updated_at	= args[:updated_at]
			end

			attr_accessor :user_id, :title, :cat, :content, :upvotes, :downvotes, :created_at, :updated_at

	end

end