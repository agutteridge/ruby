require 'singleton'
require 'set'

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
  include Enumerable

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

  # required for Enumerable module
  def each
    yield self
  end
end

class Member
  attr :library, :book_set

  def initialize(name, library)
    @name = name
    @library = library
    @book_set = Set.new
  end

  def get_name 
    @name
  end

  def check_out(book)
    @book_set.add(book)
  end

  def give_back(book)
    @book_set.delete(book)
  end

  # for naming purposes
  def return(book)
    give_back(book)
  end

  def get_books
    @book_set
  end

  def send_overdue_notice(notice)
    message = "#{@name}: #{notice}"
    puts message
    message
  end
end

class Library
  def initialize
    # read file, create books, dict of members
    @today = Calendar.instance
    @open = false
    @current_member = nil
  end

  def open
    if (@open) 
      raise 'The library is already open!'
    @today.advance
    @open = true
    "Today is day #{@today}"
  end
end

end