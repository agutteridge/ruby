require 'singleton'

class Calendar
  include Singleton

	def initialize
		@days = 0
	end

	def get_date
		@days
	end

	def advance
		@days += 1
	end
end

class Book	
	def initialize(id, title, author)
		@id = id
		@title = title
		@author = author
		@due_date = nil
	end

	def get_id
		@id
	end

	def get_title
		@title
	end

	def get_author
		@author
	end

	def get_due_date
		@due_date
	end

	def check_out(due_date)
		@due_date = due_date
	end

	def check_in
		@due_date = nil
	end

	def to_s
		"#{@id}: #{@title}, by #{@author}"
	end
end




