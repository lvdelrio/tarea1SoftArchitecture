# lib/tasks/benchmark.rake
require 'benchmark'

namespace :benchmark do
  desc "Benchmark caching for Book, Author, and Review models"
  task all: :environment do
    def run_benchmark(description)
      puts description
      result = yield
      puts result
      puts "\n"
    end

    # Book benchmarks
    book = Book.all.first
    book_id = book.id.to_s
    run_benchmark("Book.cached_find (first request):") { Benchmark.measure { Book.cached_find(book_id) } }
    run_benchmark("Book.cached_find (second request):") { Benchmark.measure { Book.cached_find(book_id) } }
    Book.clear_cache(book_id)
    run_benchmark("Book.cached_find (after cache clear):") { Benchmark.measure { Book.cached_find(book_id) } }

    # Author benchmarks
    author = Author.all.first
    author_id = author.id.to_s
    author_name = author.name
    run_benchmark("Author.cached_find (first request):") { Benchmark.measure { Author.cached_find(author_id) } }
    run_benchmark("Author.cached_find (second request):") { Benchmark.measure { Author.cached_find(author_id) } }
    Author.clear_cache(author_id)
    run_benchmark("Author.cached_find (after cache clear):") { Benchmark.measure { Author.cached_find(author_id) } }

    run_benchmark("Author.cached_find_by_name (first request):") { Benchmark.measure { Author.cached_find_by_name(author_name) } }
    run_benchmark("Author.cached_find_by_name (second request):") { Benchmark.measure { Author.cached_find_by_name(author_name) } }
    Rails.cache.delete("author_name_#{author_name}")
    run_benchmark("Author.cached_find_by_name (after cache clear):") { Benchmark.measure { Author.cached_find_by_name(author_name) } }

    # Review benchmarks
    review = Review.all.first
    review_id = review.id.to_s
    book_id = review.book_id.to_s
    run_benchmark("Review.cached_find (first request):") { Benchmark.measure { Review.cached_find(review_id) } }
    run_benchmark("Review.cached_find (second request):") { Benchmark.measure { Review.cached_find(review_id) } }
    Review.clear_cache(review_id)
    run_benchmark("Review.cached_find (after cache clear):") { Benchmark.measure { Review.cached_find(review_id) } }

    run_benchmark("Review.cached_average_score_for_book (first request):") { Benchmark.measure { Review.cached_average_score_for_book(book_id) } }
    run_benchmark("Review.cached_average_score_for_book (second request):") { Benchmark.measure { Review.cached_average_score_for_book(book_id) } }
    Rails.cache.delete("avg_score_book_#{book_id}")
    run_benchmark("Review.cached_average_score_for_book (after cache clear):") { Benchmark.measure { Review.cached_average_score_for_book(book_id) } }
  end
end