# Basic Dockerfile

A minimal Docker image built from Alpine that prints a greeting to the console. The Dockerfile is configured to display "Hello, Captain!" by default and can accept a custom name as a command-line argument.

## Technologies

Docker

## Requirements

- [x] The Dockerfile should be named Dockerfile
- [x] The base image should be `alpine:latest`
- [x] The Dockerfile should contain a single instruction to print "Hello, Captain!" to the console before exiting
- [x] Ability to pass your name to the Docker image as an argument

## Prerequisites

Docker must be installed on your machine before building or running the image.

## Usage

Build the Docker image:

```bash
docker build -t hello .
```

Run the container with the default greeting:

```bash
docker run hello
```

Pass your name as an argument:

```bash
docker run hello John
```

## Link

[roadmap.sh](https://roadmap.sh/projects/basic-dockerfile)
