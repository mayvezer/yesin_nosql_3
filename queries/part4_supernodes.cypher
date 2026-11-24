// Крок 1. Пошук вузлів з аномально великою кількістю зв'язків RATED
MATCH (n)
WHERE n:User OR n:Movie
OPTIONAL MATCH (n)-[r:RATED]-()
WITH n,
     labels(n)[0] AS label,
     COALESCE(n.title, 'User ' + toString(n.userId)) AS name,
     count(r) AS degree
RETURN label, name, degree
ORDER BY degree DESC
LIMIT 15;