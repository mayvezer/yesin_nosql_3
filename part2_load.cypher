// 1. Завантаження користувачів
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);

// 2. Завантаження фільмів
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = row.title,
    m.genres = row.genres;

// 3. Створення індексів до завантаження ребер
CREATE INDEX user_id_idx IF NOT EXISTS FOR (u:User) ON (u.userId);
CREATE INDEX movie_id_idx IF NOT EXISTS FOR (m:Movie) ON (m.movieId);

// 4. Завантаження оцінок батчами через apoc.periodic.iterate
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row RETURN row",
  "MATCH (u:User {userId: toInteger(row.userId)})
   MATCH (m:Movie {movieId: toInteger(row.movieId)})
   MERGE (u)-[r:RATED {timestamp: toInteger(row.timestamp)}]->(m)
   SET r.rating = toInteger(row.rating)",
  {batchSize: 5000, parallel: false}
);

// 5. Перевірка результату імпорту
MATCH (u:User) RETURN count(u) AS users;
MATCH (m:Movie) RETURN count(m) AS movies;
MATCH ()-[r:RATED]->() RETURN count(r) AS ratings;