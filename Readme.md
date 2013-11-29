# A simple RESTful blog server

## Architecture

Blog posts are stored in Redis

Objects are defined to manage the posts

Web Endpoints are defined (sinatra) to provide an interface and to translate between web requests and classes

## Web Endpoints

### GET /

return index.html, a MVVM frontend in JS to manage the client side

### GET /posts

returns a list of post names in JSON

### POST /posts/:name

saves a new post 
content should be JSON content.
error message should be explanation

## Code

### class Blog

manages the blog and provides interface to the parts of the blog

### class Blog::Post

manages logic behind posts
