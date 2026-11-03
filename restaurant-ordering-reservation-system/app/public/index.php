<?php
declare(strict_types=1);

// Front controller: every request that is not a real file in /public ends up here.
require __DIR__ . '/../src/bootstrap.php';
require __DIR__ . '/../src/routes.php';

dispatch();
