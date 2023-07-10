
# Node.js, MongoDB and docker-compose app

This project is a simple web application built with Node.js and MongoDB using Docker containers. It displays the number of apples stored in a MongoDB database and provides a basic "hello world" page.

## Architecture

The application architecture consists of two containers:

1.  Node.js Container: This container runs the Node.js server and serves the web application. It connects to the MongoDB container to retrieve the number of apples.
    
2.  MongoDB Container: This container runs the MongoDB database server. It stores the data for the application, including the number of apples.
    

The containers share the same Docker network, allowing them to communicate with each other.

## Prerequisites

Before running the application, make sure you have the following installed:

-   Docker: [Installation Guide](https://docs.docker.com/get-docker/)
-   Docker Compose: [Installation Guide](https://docs.docker.com/compose/install/)

## Setup

1.  Clone the repository:

`git clone https://github.com/ArielDomchik/node-mongo-dockercompose` 

2.  Install the application dependencies by running the following command:

`npm install` 

This command will install the required Node.js packages specified in the `package.json` file.

## Usage

To start the application, run the following command:

`docker-compose up` 

This command will build the Docker containers, install the dependencies, and start the application. You should see the logs indicating that the containers are running.

Access the application by opening a web browser and navigating to `http://localhost:3000`. You should see the "hello world" page along with the number of apples displayed.

## Cleaning Up

To stop the application and remove the Docker containers, run the following command:

`docker-compose down` 

This will stop and remove the containers, but the data stored in the MongoDB container will persist in the Docker volume.

----------

Feel free to customize this README file according to your specific project requirements and add any additional information that you think is relevant.

