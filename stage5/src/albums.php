<?php
// Connect to the db using db.php
require_once 'config/db.php';

// Query and saves in $artists
$stmt = $pdo->query("SELECT album.title, album.release_year, album.type, artist.name AS artist_name 
                     FROM album, artist
                     WHERE album.isni = artist.isni
                     ORDER BY album.release_year DESC");
$albums = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Music Collection - Albums</title>
</head>
<body>

    <nav>
        <a href="index.php">Artists</a> |
        <a href="albums.php">Albums</a> |
        <a href="add_album.php">Add Album</a>
    </nav>

    <hr>

    <h1>Albums catalog:</h1>

    <ul>
        <?php foreach ($albums as $album): ?>
            <li>
                <strong><?= htmlspecialchars($album['title']) ?></strong>
                - <?= htmlspecialchars($album['artist_name']) ?>
                (<?= htmlspecialchars($album['release_year']) ?>, <?=htmlspecialchars($album['type']) ?>)
            </li>
        <?php endforeach; ?>
    </ul>

</body>
</html>