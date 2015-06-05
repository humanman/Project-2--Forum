-- DROP DATABASE IF EXISTS jake_forum;
CREATE DATABASE jake_forum;
\c jake_forum
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS comments CASCADE;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  -- usernames need to be unique
  name VARCHAR NOT NULL UNIQUE,
  email VARCHAR NOT NULL UNIQUE,
  -- decipher account age
  created_at TIMESTAMP NOT NULL,
  -- http://ipinfo.io/ via JSON UPDATE loc at POST route
  loc VARCHAR,
  rating INTEGER,
  password VARCHAR NOT NULL,
  post_num INTEGER
);


CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  title VARCHAR NOT NULL,
  -- http://ipinfo.io/ via JSON UPDATE loc at POST route
  loc VARCHAR,
  -- embedded video, text, images, gifs
  cat VARCHAR CHECK (cat IN ('video','text','image','gif')),
  message TEXT,
  upvotes INTEGER,
  downvotes INTEGER,
  -- each new comment UPDATEs comment_num
  comment_num INTEGER,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);


CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  post_id INTEGER NOT NULL REFERENCES posts(id),
  message TEXT,
  -- http://ipinfo.io/ via JSON UPDATE loc at POST route
  loc VARCHAR,
  upvotes INTEGER,
  downvotes INTEGER,
  updated_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL
);

