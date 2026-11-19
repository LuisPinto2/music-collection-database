<?php
$host = 'db';
$dbname = 'music_collection';
$user = 'root';
$pass = 'rootpassword';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Erro na ligação: " . $e->getMessage());
}