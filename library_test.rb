require_relative "library"
require "test/unit"

class TestLibrary < Test::Unit::TestCase
  self.test_order = :defined

  # create instance variables of objects for all tests
  def setup
    @cal = Calendar.instance
    @book1 = Book.new(1, "1984", "George Orwell")
    @book2 = Book.new(2, "1985", "Georgina Doorbell")
    @lib = Library.new
    @mem = Member.new("Alice", @lib)
  end

  # testing the Calendar class
  # must be called before all Calendar.advance methods to pass
  def test_calendar_init
    assert_equal(0, @cal.get_date)
  end

  def test_calendar_advance
    @cal.advance
    assert_equal(1, @cal.get_date)
  end   

  # testing the Book class
  def test_book_get_id
    assert_equal(1, @book1.get_id)
  end

  def test_book_get_title
    assert_equal("1984", @book1.get_title)
  end

  def test_book_get_author
    assert_equal("George Orwell", @book1.get_author)
  end

  def test_book_get_due_date_nil
    assert_nil(@book1.get_due_date)
  end

  def test_book_check_out
    date = @cal.get_date + 14
    @book1.check_out(date)
    assert_equal(date, @book1.get_due_date)
  end

  def test_book_check_in
    @book1.check_in
    assert_nil(@book1.get_due_date)
  end

  def test_book_to_s
    assert_equal("1: 1984, by George Orwell", @book1.to_s)
  end

  # testing the Member class
  def test_member_init
    assert_equal(@lib, @mem.library)
  end

  def test_member_get_name
    assert_equal("Alice", @mem.get_name)
  end

  def test_member_no_books
    assert(@mem.get_books.empty?)
  end

  def test_member_check_out
    @mem.check_out(@book1)
    temp_set = Set.new(@book1)
    assert_equal(temp_set, @mem.get_books)
  end

  def test_member_give_back
    @mem.give_back(@book1)
    assert(@mem.get_books.empty?)
  end

  def test_member_send_overdue_notice
    assert_equal("Alice: Books are overdue", 
      @mem.send_overdue_notice("Books are overdue"))
  end

  # testing the Library class
  def test_library_init
  end

  # open
  def test_library_open_date
    tempCal = @cal.get_date
    @lib.open
    assert_equal(tempCal + 1, @cal.get_date)
  end

  def test_library_open
    assert_equal("Today is day 1.", @lib.open)
  end

  def test_library_already_open
    @lib.open
    assert_raise(Exception, @lib.open)
  end

  # find all overdue books
  def test_library_find_all_overdue_books_none
    assert_equal("No books are overdue.", @lib.find_all_overdue_books)
  end

  def test_library_find_all_overdue_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    i = 7
    while i > 0
      @lib.close
      @lib.open
      i +=1
    end
    assert_equal("Alice:\n1984, George Orwell", @lib.find_all_overdue_books)
  end

  # issue card
  def test_library_issue_card
    @lib.open
    assert_equal("Library card issued to Alice.", @lib.issue_card("Alice"))
  end

  def test_library_issue_card_already
    @lib.open
    @lib.issue_card("Alice")
    assert_equal("Alice already has a library card.", @lib.issue_card(@mem))
  end

  def test_library_issue_card_not_open
    assert_raise(Exception, @lib.issue_card(@mem))
  end

  # serve
  def test_library_serve
    @lib.open
    assert_equal("Now serving Alice", @lib.serve("Alice"))
  end

  def test_library_serve_no_card
    @lib.open
    assert_equal("Alice does not have a library card.", @lib.serve("Alice"))
  end

  def test_library_serve_not_open
    assert_raise(Exception, @lib.serve(@mem))
  end

  # find overdue books
  def test_library_find_overdue_books_none
    @lib.open
    @lib.serve("Alice")
    assert_equal("None", @lib.find_overdue_books)
  end

  def test_library_find_overdue_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    i = 7
    while i > 0
      @lib.close
      @lib.open
      i +=1
    end
    @lib.serve("Alice")
    assert_equal("1984, George Orwell", @lib.find_overdue_books)
  end

  def test_library_find_overdue_books_not_open
    assert_raise(Exception, @lib.find_all_overdue_books)
  end

  def test_library_find_overdue_books_no_member
    @lib.open
    assert_raise(Exception, @lib.find_overdue_books)
  end

  # check in
  def test_library_check_in
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    assert_equal("Alice has returned 1 book", @lib.check_in([1]))
  end    

  def test_library_check_in_multi
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1, 2])
    assert_equal("Alice has returned 2 books", @lib.check_in([1, 2]))
  end    

  def test_library_check_in_collection
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.check_in([1])
    assert_equal("1984, George Orwell", @lib.search("1984"))
  end

  def test_library_check_in_members_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.check_in([1])
    assert(@mem.get_books.empty?)
  end

  def test_library_check_in_not_open
    assert_raise(Exception, @lib.check_in([1]))
  end

  def test_library_check_in_no_member
    @lib.open
    assert_raise(Exception, @lib.check_in([1]))
  end

  def test_library_check_in_wrong_book
    @lib.open
    @lib.serve("Alice")
    assert_raise(Exception, @lib.check_in([2]))
  end

  # search
  def test_library_search_multiline
    assert_equal("1984, George Orwell\n1985, Georgina Doorbell", 
      @lib.search("198"))
  end

  def test_library_search_none
    assert_equal("No books found.", @lib.search("SDGJRIOGH"))
  end

  def test_library_search_4chars
    assert_equal("Search string must contain at least four characters.", 
      @lib.search("S"))
  end    

  # check out
  def test_library_check_out
    @lib.open
    @lib.serve("Alice")
    assert_equal("1 book has been checked out to Alice.", @lib.check_out([1]))
  end

  def test_library_check_out
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1]))
    assert_equal(7, @book1.get_due_date)
  end

  def test_library_check_out_multi
    @lib.open
    @lib.serve("Alice")
    assert_equal("2 books have been checked out to Alice.", @lib.check_out([1, 2]))
  end

  def test_library_check_out_not_open
    assert_raise(Exception, @lib.check_out([1]))
  end

  def test_library_check_out_no_member
    @lib.open
    assert_raise(Exception, @lib.check_out([1]))
  end

  def test_library_check_out_wrong_book
    @lib.open
    @lib.serve("Alice")
    assert_raise(Exception, @lib.check_out([2]))
  end

  # renew
  def test_library_renew
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    assert_equal("1 books have been renewed for Alice.", @lib.renew([1]))
  end

  def test_library_renew_dates
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.close
    @lib.open
    @lib.serve("Alice")
    @lib.renew([1])
    assert_equal(8, @book1.get_due_date)
  end

  def test_library_renew_multi
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1, 2])
    assert_equal("1 books have been renewed for Alice.", @lib.renew([1, 2]))
  end  

  def test_library_renew_not_open
    assert_raise(Exception, @lib.renew([1]))
  end

  def test_library_renew_no_member
    @lib.open
    assert_raise(Exception, @lib.renew([1]))
  end

  def test_library_renew_wrong_book
    @lib.open
    @lib.serve("Alice")
    assert_raise(Exception, @lib.renew([2]))
  end

  # close
  def library_test_close_string
    @lib.open
    assert_equal("Good night.", @lib.close)
  end

  def test_library_close_not_open
    assert_raise(Exception, @lib.close)
  end

  # quit
  def test_library_quit
    assert_equal("The library is now closed for renovations.", @lib.quit)
  end
end
