\echo '═══════════════════════════════════════════════════════════════════════════'
\echo '📘 LABORATORIO POSTGRESQL – LEMONMUSIC | BLOQUE OPCIONAL'
\echo '═══════════════════════════════════════════════════════════════════════════'

-- Todas las consultas incluyen:
--   • Enunciado original (como comentario)
--   • SELECT formateado con alias consistentes
--   • Separador visual entre consultas

\echo ' '

\echo '─────────────────────────────── 01 ────────────────────────────────'
\echo 'Listar las pistas ordenadas por el número de veces que aparecen en playlists de forma descendente'
-- Listar las pistas ordenadas por el número de veces que aparecen en playlists de forma descendente
SELECT
	t.trackid AS id,
    t.name AS track_name,
	COUNT(pt.trackid) AS playlist_count
FROM track AS t
LEFT JOIN playlisttrack AS pt
	ON t.trackid = pt.trackid
GROUP BY t.trackid, t.name
ORDER BY playlist_count DESC, t.name;

\echo ' '

\echo '─────────────────────────────── 02 ────────────────────────────────'
\echo 'Listar las pistas más compradas (la tabla InvoiceLine tiene los registros de compras)'
-- Listar las pistas más compradas (la tabla InvoiceLine tiene los registros de compras)
SELECT
	t.trackid AS id,
    t.name AS track_name,
	SUM(il.quantity) AS total_sold
FROM track AS t
JOIN invoiceline AS il
	ON t.trackid = il.trackid
GROUP BY t.trackid, t.name
ORDER BY total_sold DESC, t.name;

\echo ' '

\echo '─────────────────────────────── 03 ────────────────────────────────'
\echo 'Listar los artistas más comprados'
-- Listar los artistas más comprados
SELECT
	a.artistid AS artist_id,
	a.name AS artist_name,
	SUM(il.quantity) AS total_units_sold
FROM artist AS a
JOIN album  AS al ON a.artistid = al.artistid
JOIN track  AS t  ON al.albumid = t.albumid
JOIN invoiceline AS il ON t.trackid = il.trackid
GROUP BY a.artistid, a.name
ORDER BY total_units_sold DESC, a.name;

\echo ' '

\echo '─────────────────────────────── 04 ────────────────────────────────'
\echo 'Listar las pistas que aún no han sido compradas por nadie'
-- Listar las pistas que aún no han sido compradas por nadie
SELECT
	t.trackid AS id,
	t.name AS track_name
FROM track AS t
LEFT JOIN invoiceline AS il
	ON t.trackid = il.trackid
WHERE il.trackid IS NULL
ORDER BY t.name;

\echo ' '

\echo '─────────────────────────────── 05 ────────────────────────────────'
\echo 'Listar los artistas que aún no han vendido ninguna pista'
-- Listar los artistas que aún no han vendido ninguna pista
SELECT
	a.artistid AS artist_id,
	a.name AS artist_name
FROM artist AS a
WHERE NOT EXISTS (
	SELECT 1
	FROM album AS al
	JOIN track  AS t ON al.albumid = t.albumid
	JOIN invoiceline AS il ON t.trackid = il.trackid
	WHERE al.artistid = a.artistid
)
ORDER BY a.name;

\echo ' '



\echo '═══════════════════════════════════════════════════════════════════════════'
\echo '✅ FIN DE CONSULTAS OBLIGATORIAS'
\echo '═══════════════════════════════════════════════════════════════════════════'