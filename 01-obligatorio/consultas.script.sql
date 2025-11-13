\echo '═══════════════════════════════════════════════════════════════════════════'
\echo '📘 LABORATORIO POSTGRESQL – LEMONMUSIC | BLOQUE OBLIGATORIO'
\echo '═══════════════════════════════════════════════════════════════════════════'

-- Todas las consultas incluyen:
--   • Enunciado original (como comentario)
--   • SELECT formateado con alias consistentes
--   • Separador visual entre consultas

\echo ' '
\echo '─────────────────────────────── 01 ────────────────────────────────'
\echo 'Listar las pistas (tabla Track) con precio mayor o igual a 1€'
-- Listar las pistas (tabla Track) con precio mayor o igual a 1€
SELECT 
  t.trackid AS id,
  t.name AS track_name,
  t.unitprice AS price
FROM track AS t
WHERE t.unitprice >= 1
ORDER BY price DESC, track_name;
\echo ' '

\echo '─────────────────────────────── 02 ────────────────────────────────'
\echo 'Listar las pistas de más de 4 minutos de duración'
-- Listar las pistas de más de 4 minutos de duración
SELECT 
  t.trackid AS id,
  t.name AS track_name,
  ROUND(t.milliseconds / 60000.0, 2) AS duration_min
FROM track AS t
WHERE t.milliseconds > 4 * 60 * 1000
ORDER BY duration_min DESC;
\echo ' '

\echo '─────────────────────────────── 03 ────────────────────────────────'
\echo 'Listar las pistas que tengan entre 2 y 3 minutos de duración'
-- Listar las pistas que tengan entre 2 y 3 minutos de duración
SELECT
  t.trackid AS id,
  t.name AS track_name,
	ROUND(t.milliseconds / 60000.0, 2) AS duration_min
FROM track AS t
WHERE t.milliseconds BETWEEN 2 * 60 * 1000 AND 3 * 60 * 1000
ORDER BY duration_min DESC;

\echo ' '

\echo '─────────────────────────────── 04 ────────────────────────────────'
\echo 'Listar las pistas que uno de sus compositores (columna Composer) sea Mercury'
-- Listar las pistas que uno de sus compositores (columna Composer) sea Mercury
SELECT
  t.trackid AS id,
  t.name AS track_name,
  t.composer
FROM track AS t
WHERE t.composer ILIKE '%Mercury%'
ORDER BY t.name;

\echo ' '

\echo '─────────────────────────────── 05 ────────────────────────────────'
\echo 'Calcular la media de duración de las pistas (Track) de la plataforma'
-- Calcular la media de duración de las pistas (Track) de la plataforma
SELECT
	ROUND(AVG(t.milliseconds / 60000.0), 2) as average_duration_min
FROM track AS t;

\echo ' '

\echo '─────────────────────────────── 06 ────────────────────────────────'
\echo 'Listar los clientes (tabla Customer) de USA, Canada y Brazil'
-- Listar los clientes (tabla Customer) de USA, Canada y Brazil
SELECT
  c.customerid AS customer_id,
  c.firstname AS first_name,
  c.lastname AS last_name,
  c.country
FROM customer AS c
WHERE c.country IN ('USA', 'Canada', 'Brazil')
ORDER BY c.country, customer_id;

\echo ' '

\echo '─────────────────────────────── 07 ────────────────────────────────'
\echo 'Listar todas las pistas del artista 'Queen' (Artist.Name = 'Queen')'
-- Listar todas las pistas del artista 'Queen' (Artist.Name = 'Queen')
SELECT
  t.trackid AS id,
  t.name AS track_name,
  a.name AS artist_name
FROM track AS t
JOIN album AS al
	ON t.albumid = al.albumid
JOIN artist AS a
	ON al.artistid = a.artistid
WHERE a.name = 'Queen'
ORDER BY t.name DESC;

\echo ' '

\echo '─────────────────────────────── 08 ────────────────────────────────'
\echo 'Listar las pistas del artista 'Queen' en las que haya participado como compositor David Bowie'
-- Listar las pistas del artista 'Queen' en las que haya participado como compositor David Bowie
SELECT
  t.trackid AS id,
  t.name AS track_name,
  a.name AS artist_name,
  t.composer AS composers
FROM track AS t
JOIN album AS al
	ON t.albumid = al.albumid
JOIN artist AS a
	ON al.artistid = a.artistid
WHERE a.name = 'Queen'
	AND t.composer ILIKE '%David Bowie%'
ORDER BY t.name DESC;

\echo ' '

\echo '─────────────────────────────── 09 ────────────────────────────────'
\echo 'Listar las pistas de la playlist 'Heavy Metal Classic''
-- Listar las pistas de la playlist 'Heavy Metal Classic'
SELECT
	t.trackid AS id,
  t.name AS track_name,
	p.name AS playlist_name
FROM playlist AS p
JOIN playlisttrack AS pt
	ON p.playlistid = pt.playlistid
JOIN track as t
	ON pt.trackid = t.trackid
WHERE p.name = 'Heavy Metal Classic'
ORDER BY t.name;

\echo ' '

\echo '─────────────────────────────── 10 ────────────────────────────────'
\echo 'Listar las playlist junto con el número de pistas que contienen'
-- Listar las playlist junto con el número de pistas que contienen
SELECT
	p.name AS playlist_name,
	COUNT(pt.trackid) AS track_count
FROM playlist AS p
LEFT JOIN playlisttrack AS pt
	ON p.playlistid = pt.playlistid
GROUP BY p.playlistid, p.name
ORDER BY track_count DESC, p.name;

\echo ' '

\echo '─────────────────────────────── 11 ────────────────────────────────'
\echo 'Listar las playlist (sin repetir ninguna) que tienen alguna canción de AC/DC'
-- Listar las playlist (sin repetir ninguna) que tienen alguna canción de AC/DC
SELECT
	p.name AS playlist_name,
	COUNT(t.trackid) AS acdc_track_count
FROM playlist AS p
JOIN playlisttrack AS pt
	ON p.playlistid = pt.playlistid
JOIN track as t
	ON pt.trackid = t.trackid
JOIN album AS al
	ON t.albumid = al.albumid
JOIN artist AS a
	ON al.artistid = a.artistid
WHERE a.name ILIKE 'AC/DC'
GROUP BY p.name
ORDER BY acdc_track_count DESC;

\echo ' '

\echo '─────────────────────────────── 12 ────────────────────────────────'
\echo 'Listar las playlist que tienen alguna canción del artista Queen, junto con la cantidad que tienen'
-- Listar las playlist que tienen alguna canción del artista Queen, junto con la cantidad que tienen
SELECT
	p.name AS playlist_name,
	COUNT(t.trackid) AS queen_track_count
FROM playlist AS p
JOIN playlisttrack AS pt
	ON p.playlistid = pt.playlistid
JOIN track as t
	ON pt.trackid = t.trackid
JOIN album AS al
	ON t.albumid = al.albumid
JOIN artist AS a
	ON al.artistid = a.artistid
WHERE a.name ILIKE 'Queen'
GROUP BY p.name
ORDER BY queen_track_count DESC;

\echo ' '

\echo '─────────────────────────────── 13 ────────────────────────────────'
\echo 'Listar las pistas que no están en ninguna playlist'
-- Listar las pistas que no están en ninguna playlist
SELECT
	t.trackid AS track_id,
	t.name AS track_name
FROM track AS t
LEFT JOIN playlisttrack AS pt
	ON t.trackid = pt.trackid
WHERE pt.trackid IS NULL
ORDER BY t.name;

\echo ' '

\echo '─────────────────────────────── 14 ────────────────────────────────'
\echo 'Listar los artistas que no tienen album'
-- Listar los artistas que no tienen album
SELECT
	a.artistid AS artist_id,
	a.name AS artist_name,
	COUNT(al.albumid) AS album_count
FROM artist AS a
LEFT JOIN album AS al
	ON a.artistid = al.artistid
GROUP BY a.artistid, a.name
HAVING COUNT(al.albumid) = 0
ORDER BY a.name;

\echo ' '

\echo '─────────────────────────────── 15 ────────────────────────────────'
\echo 'Listar los artistas con el número de albums que tienen'
-- Listar los artistas con el número de albums que tienen
SELECT
	a.artistid AS artist_id,
	a.name AS artist_name,
	COUNT(al.albumid) AS album_count
FROM artist AS a
LEFT JOIN album AS al
	ON a.artistid = al.artistid
GROUP BY a.artistid, a.name
ORDER BY album_count DESC, a.name;

\echo ' '



\echo '═══════════════════════════════════════════════════════════════════════════'
\echo '✅ FIN DE CONSULTAS OBLIGATORIAS'
\echo '═══════════════════════════════════════════════════════════════════════════'
