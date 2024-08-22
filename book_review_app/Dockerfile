# Use the official Ruby image
FROM ruby:3.3.3-slim

# Set the working directory in the container
WORKDIR /rails

# Install system dependencies required for Rails and the cassandra-driver gem
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libssl-dev \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Set the entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Expose port 3000
EXPOSE 3000

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]