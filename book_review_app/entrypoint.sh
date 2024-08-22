#!/bin/bash
set -e

echo "Starting entrypoint script..."

# Set CASSANDRA_HOST if not already set
export CASSANDRA_HOST=${CASSANDRA_HOST:-cassandra}
export CASSANDRA_KEYSPACE=${CASSANDRA_KEYSPACE:-"book_review_app_${RAILS_ENV:-development}"}

# Wait for Cassandra to be ready
echo "Waiting for Cassandra to be ready..."
until nc -z $CASSANDRA_HOST 9042; do
  echo "Cassandra is not ready yet. Retrying in 2 seconds..."
  sleep 2
done

echo "Cassandra is up and running!"

# Print current directory and list files
echo "Current directory: $(pwd)"
echo "Files in current directory:"
ls -la

# Print Rails environment
echo "Rails environment: $RAILS_ENV"

# Setup the Cassandra keyspace
echo "Setting up Cassandra keyspace..."
bundle exec rake cassandra:setup

echo "Setting up fake data..."
bundle exec rake dummy_data:create

# Start the Rails server
echo "Starting Rails server..."
exec "$@"