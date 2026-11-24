// Запит 1. Фільми жанру "Thriller" із середнім рейтингом вище 4.0
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE m.genres CONTAINS 'Thriller'
WITH m, avg(r.rating) AS avg_rating, count(r) AS ratings_count
WHERE avg_rating > 4.0
RETURN m.movieId AS movieId, m.title AS title, avg_rating, ratings_count
ORDER BY avg_rating DESC
LIMIT 10;

// Запит 2. Користувачі, які поставили оцінку 5 більш ніж 50 фільмам
MATCH (u:User)-[r:RATED {rating: 5}]->(m:Movie)
WITH u, count(m) AS five_star_count
WHERE five_star_count > 50
RETURN u.userId AS userId, u.gender AS gender, u.age AS age, five_star_count
ORDER BY five_star_count DESC
LIMIT 10;

// Запит 3. Фільми, які обидва користувачі (userId=1 і userId=2) оцінили високо (rating >= 4)
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.movieId AS movieId, m.title AS title, r1.rating AS rating_u1, r2.rating AS rating_u2;

// Запит 4. Жанри: середній рейтинг та кількість оцінок
MATCH (u:User)-[r:RATED]->(m:Movie)
UNWIND split(m.genres, '|') AS genre
WITH genre, avg(r.rating) AS avg_rating, count(r) AS ratings_count
WHERE ratings_count > 0
RETURN genre, avg_rating, ratings_count
ORDER BY avg_rating DESC, ratings_count DESC
LIMIT 10;

// Запит 5. Рекомендація "користувачі зі схожими смаками також дивилися" для userId=1
MATCH (target:User {userId: 1})-[r1:RATED]->(common:Movie)<-[r2:RATED]-(similar:User)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND target <> similar
WITH target, similar, count(common) AS common_movies
ORDER BY common_movies DESC
LIMIT 15
MATCH (similar)-[r3:RATED]->(rec:Movie)
WHERE r3.rating >= 4 AND NOT (target)-[:RATED]->(rec)
RETURN rec.movieId AS movieId,
       rec.title AS title,
       count(DISTINCT similar) AS recommended_by_similar_users,
       avg(r3.rating) AS avg_similar_rating
ORDER BY recommended_by_similar_users DESC, avg_similar_rating DESC
LIMIT 10;

// Запит 6. Найкоротший ланцюжок зв'язку між двома користувачами через спільні фільми
MATCH path = shortestPath(
  (u1:User {userId: 1})-[:RATED*1..6]-(u2:User {userId: 10})
)
RETURN length(path) AS path_length,
       [n IN nodes(path) | COALESCE(n.title, 'User ' + toString(n.userId))] AS chain_nodes
LIMIT 1;