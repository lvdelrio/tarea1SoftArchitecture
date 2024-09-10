require 'benchmark'

namespace :benchmark do
  desc "Benchmark Book.cached_find"
  task book_cached_find: :environment do
    puts "First request:"
    puts Benchmark.measure { book1 = Book.cached_find('1aa65e56-6e3a-11ef-8a6e-0311d2275c28') }

    puts "\nSecond request:"
    puts Benchmark.measure { book2 = Book.cached_find('1aa65e56-6e3a-11ef-8a6e-0311d2275c28') }

    puts "\nClearing cache..."
    Book.clear_cache('1aa65e56-6e3a-11ef-8a6e-0311d2275c28')

    puts "\nThird request (after cache clear):"
    puts Benchmark.measure { book3 = Book.cached_find('1aa65e56-6e3a-11ef-8a6e-0311d2275c28') }
  end
end