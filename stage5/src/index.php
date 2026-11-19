<?php
// Connect to the db using db.php
require_once 'config/db.php';

// Query and saves in $artists
$stmt = $pdo->query("SELECT isni, name, activity_start_year 
                     FROM artist ORDER BY name");
$artists = $stmt->fetchAll(PDO::FETCH_ASSOC);               # FETCH_ASSOC: Associative Array; 0 => ['isni' => ..., 'name' => ...] 
?>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Music Collection - Artistas</title>
</head>
<body>

    <nav>
        <a href="index.php">Artistas</a> |
        <a href="albuns.php">Álbuns</a>
    </nav>

    <hr>

    <h1>Lista de Artistas</h1>

    <ul>
        <?php foreach ($artists as $artist): ?>
            <li>
                <strong><?= htmlspecialchars($artist['name']) ?></strong>
                (desde <?= htmlspecialchars($artist['activity_start_year']) ?>)
            </li>
        <?php endforeach; ?>
    </ul>

</body>
</html>