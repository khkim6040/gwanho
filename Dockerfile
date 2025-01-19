# Stage 1: Build
FROM ruby:3.4.1-slim AS builder

# Install dependencies for building gems
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 \
    && rm -rf ~/.bundle/cache

# Stage 2: Runtime
FROM ruby:3.4.1-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy only necessary files from the build stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . .

# Expose the port Jekyll runs on
EXPOSE 4000

# Start Jekyll
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000"]