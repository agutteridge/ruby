require_relative "library"
require "test/unit"

class TestLibrary < Test::Unit::TestCase

	# create instance variables of objects for all tests
  def setup
  	@cal = Calendar.new
  	@book = Book.new(1, "1984", "George Orwell")
  end

	# testing the Calendar class
  def test_calendar_init
		assert_equal(0, @cal.get_date)
	end

	def test_calendar_advance
		@cal.advance
		assert_equal(1, @cal.get_date)
	end		

	# testing the Book class
	def test_book_get_id
		assert_equal(1, @book.get_id)
	end

	def test_book_get_title
		assert_equal('1984', @book.get_title)
	end

	def test_book_get_author
		assert_equal('George Orwell', @book.get_author)
	end

	def test_book_get_due_date_nil
		assert_nil(@book.get_due_date)
	end

	def test_book_check_out
		date = @cal.get_date + 14
		@book.check_out(date)
		assert_equal(date, @book.get_due_date)
	end

	def test_book_check_in
		@book.check_in
		assert_nil(@book.get_due_date)
	end

	def test_book_to_s
		assert_equal("1: 1984, by George Orwell", @book.to_s)
	end

end
