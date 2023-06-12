# Using the latest Debian Slim as the base image
FROM debian:bookworm-slim

# Set environment variables for the databases and the user
ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=test
ENV MYSQL_USER=test
ENV MYSQL_PASSWORD=test

ENV POSTGRES_PASSWORD=test
ENV POSTGRES_USER=test
ENV POSTGRES_DB=test

# Update Debian Software repository
RUN apt-get update

# Install sudo
RUN apt-get install -y sudo

# Install MariaDB
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y mariadb-server

# Install PostgreSQL
RUN apt-get install -y postgresql postgresql-contrib

# Install Node.js (latest LTS)
RUN apt-get install -y curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

# Install nano (optional, for debugging)
RUN apt-get install -y nano

# Configure databases
COPY configure_database.sh /tmp/
RUN chmod +x /tmp/configure_database.sh
RUN /tmp/configure_database.sh
RUN rm /tmp/configure_database.sh

# Initialize databases and users
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh

# Expose ports
EXPOSE 3306 5432

# Run the setup script
CMD ["/setup.sh"]
