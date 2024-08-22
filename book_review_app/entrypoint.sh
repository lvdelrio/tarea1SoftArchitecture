#!/bin/bash
set -e

echo "Starting entrypoint script..."
export CASSANDRA_HOST=${CASSANDRA_HOST:-cassandra}
export CASSANDRA_KEYSPACE=${CASSANDRA_KEYSPACE:-"book_review_app_${RAILS_ENV:-development}"}

echo "Waiting for Cassandra to be ready..."
until nc -z $CASSANDRA_HOST 9042; do
  echo "Cassandra is not ready yet. Retrying in 2 seconds..."
  sleep 2
done

echo "Cassandra is up and running!"

echo "Current directory: $(pwd)"
echo "Files in current directory:"
ls -la

echo "Rails environment: $RAILS_ENV"

echo "Setting up Cassandra keyspace..."
bundle exec rake cassandra:setup

echo "Setting up fake data..."
bundle exec rake dummy_data:create


echo "Starting Rails server..."
exec "$@"