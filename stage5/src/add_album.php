<?php
require_once 'config/db.php';

$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = trim($_POST['title'] ?? '');
    $release_year = $_POST['release_year'] ?? '';
    $type = $_POST['type'] ?? '';
    $isni = $_POST['isni'] ?? '';

    // Server validation
    if ($title === '') {
        $errors[] = "Album title is required.";
    }
    if ($isni === '') {
        $errors[] = "Please select an artist.";
    }
    if (!is_numeric($release_year) || $release_year < 1900 || $release_year > 2026) {
        $errors[] = "Please enter a valid release year (1900–2026).";
    }

    // Verify if album already exists for this artist
    if (empty($errors)) {
        $check = $pdo->prepare("SELECT mbid 
                                FROM album 
                                WHERE title = :title 
                                AND isni = :isni");
        $check->execute([
            ':title' => $title,
            ':isni' => $isni
        ]);

        if ($check->fetch(PDO::FETCH_ASSOC)) {
            $errors[] = "This album is already registered in the catalog for this artist.";
        }
    }

    // If everything is ok generate UUID and save
    if (empty($errors)) {
        $mbid = sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );

        $stmt = $pdo->prepare("
            INSERT INTO album (mbid, title, release_year, type, isni)
            VALUES (:mbid, :title, :release_year, :type, :isni)
        ");

        $stmt->execute([
            ':mbid' => $mbid,
            ':title' => $title,
            ':release_year' => $release_year,
            ':type' => $type,
            ':isni' => $isni
        ]);

        header("Location: albums.php");
        exit;
    }
}

// Search for existent artists for dropdown
$stmt = $pdo->query("SELECT isni, name FROM artist ORDER BY name");
$artists = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Music Collection - Add Album</title>
</head>
<body>

    <nav>
        <a href="index.php">Artists</a> |
        <a href="albums.php">Albums</a> |
        <a href="add_album.php">Add Album</a>
    </nav>

    <hr>

    <h1>Add New Album to Catalog</h1>

    <?php if (!empty($errors)): ?>
        <ul style="color: red;">
            <?php foreach ($errors as $error): ?>
                <li><?= htmlspecialchars($error) ?></li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>

    <form method="POST" action="add_album.php">
        <p>
            <label>Title:</label><br>
            <input type="text" name="title" value="<?= htmlspecialchars($_POST['title'] ?? '') ?>" required>
        </p>

        <p>
            <label>Artist:</label><br>
            <select name="isni" required>
                <option value="">-- Select an artist --</option>
                <?php foreach ($artists as $artist): ?>
                    <option value="<?= htmlspecialchars($artist['isni']) ?>"
                        <?= (($_POST['isni'] ?? '') == $artist['isni']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($artist['name']) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </p>

        <p>
            <label>Release Year:</label><br>
            <input type="number" name="release_year" min="1900" max="2026"
                   value="<?= htmlspecialchars($_POST['release_year'] ?? '') ?>" required>
        </p>

        <p>
            <label>Type:</label><br>
            <select name="type" required>
                <option value="Studio">Studio</option>
                <option value="Live">Live</option>
                <option value="Compilation">Compilation</option>
                <option value="EP">EP</option>
            </select>
        </p>

        <button type="submit">Save Album</button>
    </form>

</body>
</html>