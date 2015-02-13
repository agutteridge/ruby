require_relative "library"
require "test/unit"

class TestLibrary < Test::Unit::TestCase
  self.test_order = :defined

  # create instance variables of objects for all tests
  def setup
    @cal = Calendar.instance
    @book = Book.new(1, "1984", "George Orwell")
    @lib = Library.new
    @mem = Member.new("Anon", @lib)
    @lib.open
    @lib.issue_card("Alice")
    @lib.close
  end

  # testing the Calendar class
  # must be called before all Calendar.advance methods to pass
  def test_calendar_init
    assert_equal(1, @cal.get_date)
  end

  def test_calendar_advance
    start = @cal.get_date
    @cal.advance
    assert_equal(start + 1, @cal.get_date)
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

  def test_member_get_name
    assert_equal("Anon", @mem.get_name)
  end

  def test_member_no_books
    assert(@mem.get_books.empty?)
  end

  def test_member_check_out
    @mem.check_out(@book)
    temp_set = Set.new(@book)
    assert_equal(temp_set, @mem.get_books)
  end

  def test_member_give_back
    @mem.give_back(@book)
    assert(@mem.get_books.empty?)
  end

  def test_member_send_overdue_notice
    assert_equal("Anon: Books are overdue", 
      @mem.send_overdue_notice("Books are overdue"))
  end

  # open
  def test_library_open
    start = @cal.get_date + 1
    assert_equal("Today is day #{start}.", @lib.open)
  end

  def test_library_open_date
    tempCal = @cal.get_date
    @lib.open
    assert_equal(tempCal + 1, @cal.get_date)
  end

  def test_library_already_open
    @lib.open
    assert_raise do @lib.open
    end
  end

  # find all overdue books
  def test_library_find_all_overdue_books_none
    @lib.open
    assert_equal("No books are overdue.", @lib.find_all_overdue_books)
  end

  def test_library_find_all_overdue_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    i = 8
    while i > 0
      @lib.close
      @lib.open
      i -= 1
    end
    assert_equal("Overdue books for Alice:\n1: 1984, by George Orwell\n", 
      @lib.find_all_overdue_books)
  end

  def test_library_find_all_overdue_books_multiline
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.issue_card("Fred")
    @lib.serve("Fred")
    @lib.check_out([3,4])
    i = 8
    while i > 0
      @lib.close
      @lib.open
      i -= 1
    end
    assert_equal("Overdue books for Alice:\n1: 1984, by George Orwell\nOverdue books for Fred:\n3: The Cider House Rules, by John Irving\n4: Atlas Shrugged, by Ayn Rand\n", 
      @lib.find_all_overdue_books)
  end

  # issue card
  def test_library_issue_card
    @lib.open
    assert_equal("Library card issued to Fred.", @lib.issue_card("Fred"))
  end

  def test_library_issue_card_already
    @lib.open
    assert_equal("Alice already has a library card.", @lib.issue_card("Alice"))
  end

  def test_library_issue_card_not_open
    assert_raise do @lib.issue_card("Alice")
    end
  end

  # serve
  def test_library_serve
    @lib.open
    assert_equal("Now serving Alice", @lib.serve("Alice"))
  end

  def test_library_serve_current
    @lib.open
    @lib.serve("Alice")
    assert_equal("Alice", @lib.current_member.get_name)
  end

  def test_library_serve_no_card
    @lib.open
    assert_equal("Fred does not have a library card.", @lib.serve("Fred"))
  end

  def test_library_serve_not_open
    assert_raise do @lib.serve("Alice")
    end
  end

  # find overdue books
  def test_library_find_overdue_books_none
    @lib.open
    @lib.serve("Alice")
    assert_equal("Overdue books for Alice:\nNone", @lib.find_overdue_books)
  end

  def test_library_find_overdue_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    i = 8
    while i > 0
      @lib.close
      @lib.open
      i -=1
    end
    @lib.serve("Alice")
    assert_equal("Overdue books for Alice:\n1: 1984, by George Orwell\n", 
      @lib.find_overdue_books)
  end

  def test_library_find_overdue_books_not_open
    assert_raise do @lib.find_overdue_books
    end
  end

  def test_library_find_overdue_books_no_member
    @lib.open
    assert_raise do @lib.find_overdue_books
    end
  end

  # check in
  def test_library_check_in
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    assert_equal("Alice has returned 1 book.", @lib.check_in([1]))
  end

  def test_library_check_in_current
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.check_in([1])
    assert(@lib.current_member.get_books.empty?)
  end

  def test_library_check_in_multi
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1,2])
    assert_equal("Alice has returned 2 books.", @lib.check_in([1, 2]))
  end    

  def test_library_check_in_collection
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.check_in([1])
    assert_equal("1: 1984, by George Orwell\n", @lib.search("1984"))
  end

  def test_library_check_in_members_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.check_in([1])
    assert(@lib.current_member.get_books.empty?)
  end

  def test_library_check_in_not_open
    assert_raise do @lib.check_in([1])
    end
  end

  def test_library_check_in_no_member
    @lib.open
    assert_raise do @lib.check_in([1])
    end
  end

  def test_library_check_in_wrong_book
    @lib.open
    @lib.serve("Alice")
    assert_raise do @lib.check_in([2])
    end
  end

  # search
  def test_library_search_multiline
    assert_equal("1: 1984, by George Orwell\n5: 1985, by Georgina Doorbell", 
      @lib.search("geor"))
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

  def test_library_check_out_current
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    assert(!@lib.current_member.get_books.empty?)
  end

  def test_library_check_out_multi
    @lib.open
    @lib.serve("Alice")
    assert_equal("2 books have been checked out to Alice.", @lib.check_out([1, 2]))
  end

  def test_library_check_out_over3_at_once
    @lib.open
    @lib.serve("Alice")
    assert_raise do @lib.check_out([1,2,3,4])
    end
  end

  def test_library_check_out_over3_individual
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.check_out([2])
    @lib.check_out([3])
    assert_raise do @lib.check_out([4])
    end
  end
  
  def test_library_check_out_not_open
    assert_raise do @lib.check_out([1])
    end
  end

  def test_library_check_out_no_member
    @lib.open
    assert_raise do @lib.check_out([1])
    end
  end

  def test_library_check_out_wrong_book
    @lib.open
    @lib.serve("Alice")
    assert_raise do @lib.check_out([99])
    end
  end

  # renew
  def test_library_renew
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    assert_equal("1 book has been renewed for Alice.", @lib.renew([1]))
  end

  def test_library_renew_current
    start = @cal.get_date # e.g. date = 0
    @lib.open # date = 1
    @lib.serve("Alice")
    @lib.check_out([1])
    @lib.close
    @lib.open # date = 2
    @lib.serve("Alice")
    @lib.renew([1]) # new due date = 2 + 7 = 9
    assert_equal(start + 9, check_due_date(1, @lib.current_member))
  end

  # helper method for test_library_renew_current
  def check_due_date(id, mem)
    date_array = Array.new

    mem.get_books.each do |b|
      date_array << b.get_due_date
    end

    date_array[0]
  end

  def test_library_renew_multi
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1, 2])
    assert_equal("2 books have been renewed for Alice.", @lib.renew([1, 2]))
  end  

  def test_library_renew_members_books
    @lib.open
    @lib.serve("Alice")
    @lib.check_out([1])
    assert_equal("1 book has been renewed for Alice.", @lib.renew([1]))
  end    

  def test_library_renew_not_open
    assert_raise do @lib.renew([1])
    end
  end

  def test_library_renew_no_member
    @lib.open
    assert_raise do @lib.renew([1])
    end
  end

  def test_library_renew_wrong_book
    @lib.open
    @lib.serve("Alice")
    assert_raise do @lib.renew([2])
    end
  end

  # close
  def library_test_close_string
    @lib.open
    assert_equal("Good night.", @lib.close)
  end

  def test_library_close_not_open
    assert_raise do @lib.close
    end
  end

  # quit
  def test_library_quit
    assert_equal("The library is now closed for renovations.", @lib.quit)
  end
end
