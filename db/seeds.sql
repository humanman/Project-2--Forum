TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE posts CASCADE;
TRUNCATE TABLE comments CASCADE;

INSERT INTO users (id, name, created_at, loc, rating, password, post_num) VALUES (1, 'humanman',CURRENT_TIMESTAMP, 'New York', 100, '12345', 5);
INSERT INTO posts (id, user_id, title, created_at, loc, cat, message, upvotes, downvotes, comment_num) VALUES (1, 1, 'My cat', CURRENT_TIMESTAMP, 'image', 'this is a pic of my cat[href to cat]', 9, 2, 3);
INSERT INTO comments (id, user_id, post_id, message, created_at, loc, upvotes, downvotes) VALUES (3, 1, 1,CURRENT_TIMESTAMP, 'your mom is a whore', 'New York', 4, 50);