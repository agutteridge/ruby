require_relative "library"
require "test/unit"

class TestLibrary < Test::Unit::TestCase

  # create instance variables of objects for all tests
  def setup
    @cal = Calendar.instance
    @book = Book.new(1, "1984", "George Orwell")
    @lib = Library.new
    @mem = Member.new("Alice", @lib)
  end

  # testing the Calendar class
  # must be called before all Calendar.advance methods to pass
  def test_0_calendar_init
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
    assert_equal("1984", @book.get_title)
  end

  def test_book_get_author
    assert_equal("George Orwell", @book.get_author)
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

  # testing the Member class
  def test_member_init
    assert_equal(@lib, @mem.library)
  end

  def test_member_get_name
    assert_equal("Alice", @mem.get_name)
  end

  def test_member_0_no_books
    assert(@mem.get_books.empty?)
  end

  def test_member_1_check_out
    @mem.check_out(@book)
    temp_set = Set.new(@book)
    assert_equal(temp_set, @mem.get_books)
  end

  def test_member_2_give_back
    @mem.give_back(@book)
    assert(@mem.get_books.empty?)
  end

  def test_member_send_overdue_notice
    assert_equal("Alice: Books are overdue", 
      @mem.send_overdue_notice("Books are overdue"))
  end
end
