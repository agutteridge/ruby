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
    @all_books = Array.new
    @all_members = {}
    # set default value to nil so an Exception is not raised
    # if fetch is called and the key does not exist
    @all_members.default = nil

    IO.foreach("collection.txt") { |x| add_book(x) }

    @today = Calendar.instance
    @open = false
    @current_member = nil
  end

  # helper method for initialize
  # lines in collection.txt must be tab-delimited
  def add_book(line)
    title, author = line.split("\t")

    num = @all_books.size + 1
    new_book = Book.new(num, title, author)
    @all_books << new_book
  end

  def open
    if @open 
      raise 'The library is already open!'
    end
    @today.advance
    @open = true
    "Today is day #{@today.get_date}"
  end

  # if library is closed, an Exception is raised
  def is_not_open
    if !@open 
      raise 'The library is not open'
    end
  end

  # if current_member is set to nil i.e. no member is being served
  # an Exception is raised
  def no_member
    if @current_member == nil
      raise 'No member is currently being served'
    end
  end

  def find_all_overdue_books
    overdue = false
    result = ""

    @all_members.each do |m| 
      puts "#{m.get_name}: \n"
      current_member = m
      s = find_overdue_books
      if s != "None"
        overdue = true
      end 
    end

    if !overdue
      result = "No books are overdue."
    end
    
    puts result
    result
  end

  def issue_card(name_of_member)
    is_not_open

    if @all_members.include? name_of_member
      "#{name_of_member} already has a library card."
    else
      Member.new(name_of_member, self)
      "Library card issued to #{name_of_member}."
    end
  end

  def serve(name_of_member)
    is_not_open

    @current_member = @all_members.fetch(name_of_member)
    # default value is nil
    if @current_member.nil?
      "#{name_of_member} does not have a library card."
    else
      "Now serving #{name_of_member}"
    end
  end

  def find_overdue_books
    is_not_open
    no_member

    overdue = false

    @current_member.get_books.each do |b| 
      if (b.get_due_date < @today.get_date)
        overdue = true
        result << "#{b.to_s}\n"
      end
    end

    # string is printed, but also returned
    # for testing purposes and for find_all_overdue_books
    if !overdue
      result = "None"
    end
    
    puts result
    result
  end

  def check_in(book_numbers)
    is_not_open
    no_member

    book_numbers.each do |b| 
      book = find_book_by_id(b, @current_member.get_books)
      if book.nil?
        raise "The member does not have book #{b}"
      end
      @current_member.give_back(book)
      book.check_in
      @all_books << book
      "#{@current_member.get_name} has returned #{book_numbers.size} books."
    end
  end

  # searching through a data structure for a book using id
  def find_book_by_id(id, book_collection)
    book_collection.each do |b|
      if b.get_id == id
        b
      end
    end
    # returns nil if no book is found
    nil
  end

  def search(string)
    if string.length < 4
      "Search string must contain at least four characters."
    else
      result_array = Array.new
      s = string.downcase

      @all_books.each do |b| 
      if b.get_title.downcase.include?(s)
        result_array << b
      elsif b.get_author.downcase.include?(s)
        result_array << b
      end
    
      if result_array.empty?
        "No books found."
      else
        result = ""
        result_array.each do |r|
          result << r.to_s
        end

        result
      end
    end
  end

  def check_out(book_ids)
    is_not_open
    no_member

    book_ids.each do |b| 
      book = find_book_by_id(b, @all_books)
      if book.nil?
        raise "The library does not have book #{b}"
      end
      @current_member.check_out(book)
      book.check_out(@today.get_date + 7)
      @all_books.delete(book)
      "#{book_ids.size} have been checked out to #{@current_member.get_name}."
    end
  end

  def renew(book_ids)
    is_not_open
    no_member

    book_ids.each do |b| 
      book = find_book_by_id(b, @current_member.get_books)
      if book.nil?
        raise "The member does not have book #{b}"
      end
      book.check_out(@today.get_date + 7)
      "#{book_ids.size} have been renewed for #{@current_member.get_name}."
    end
  end

  def close
    is_not_open
    @open = false
    "Good night."
  end

  def quit
    "The library is now closed for renovations"
  end
end
