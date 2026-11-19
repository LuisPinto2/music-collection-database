<?php
// Connect to the db using db.php
require_once 'config/db.php';

// Query and saves in $artists
$stmt = $pdo->query("SELECT isni, name, activity_start_year 
                     FROM artist 
                     ORDER BY name");
$artists = $stmt->fetchAll(PDO::FETCH_ASSOC);               # FETCH_ASSOC: Associative Array; 0 => ['isni' => ..., 'name' => ...] 
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Music Collection - Artists</title>
</head>
<body>

    <nav>
        <a href="index.php">Artists</a> |
        <a href="albums.php">Albums</a> |
        <a href="add_album.php">Add Album</a>
    </nav>

    <hr>

    <h1>Artists:</h1>

    <ul>
        <?php foreach ($artists as $artist): ?>
            <li>
                <strong><?= htmlspecialchars($artist['name']) ?></strong>
                (since <?= htmlspecialchars($artist['activity_start_year']) ?>)
            </li>
        <?php endforeach; ?>
    </ul>

</body>
</html>