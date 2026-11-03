<?php
require __DIR__ . '/config/db.php';

try {
    $pdo = getConnection();
    $row = $pdo->query('SELECT current_database() AS db, version() AS v')->fetch();
    echo 'Connected to: ' . htmlspecialchars($row['db']) . '<br>' . htmlspecialchars($row['v']);
} catch (PDOException $e) {
    echo 'Connection failed: ' . htmlspecialchars($e->getMessage());
}