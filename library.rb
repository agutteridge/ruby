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
    @all_books = Array.new
    @all_members = {}

    IO.foreach("collection.txt") { |x| add_book(x) }

    @today = Calendar.instance
    @open = false
    @current_member = nil
  end

  def add_book(line)
    # appears to have newline at the end?
    title = line.sub(/\t.*/, "")
    author = line.sub(/.*\t/, "")
    title.sub!(/\n/, "")
    author.sub!(/\n/, "")

    num = @all_books.size + 1
    new_book = Book.new(num, title, author)
    @all_books << new_book
  end

  def open
    if (@open) 
      raise 'The library is already open!'
    @today.advance
    @open = true
    "Today is day #{@today.get_date}"
  end

  def find_all_overdue_books
    # horrible!
    @all_members.each do |m| 
      m.get_books.each do |b| 
        if (b.get_due_date < @today.get_date)
          puts b.to_s
        end
      end
    end
  end

  def issue_card(name_of_member)
    if !@open raise 'The library is not open'
    end

    if @all_members.include? name_of_member
      "#{name_of_member} already has a library card."
    else
      Member.new(name_of_member, self)
      "Library card issued to #{name_of_member}."
    end
  end

  def serve(name_of_member)
    @all_members.fetch(name_of_member)
  end
end

end