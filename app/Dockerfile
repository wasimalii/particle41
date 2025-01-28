# Node base image
FROM node:18-alpine

# Copying the application code inside the container
COPY . /my_app/

# set work directory to install dependencies
WORKDIR /my_app/

# Installing dependencies
RUN npm install


# create a non-root user appuser to run the application
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# expose the port on which our app run
EXPOSE 5000

# run the app
CMD ["node", "app.js"]
