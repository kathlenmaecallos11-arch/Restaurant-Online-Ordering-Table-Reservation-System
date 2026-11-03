<?php
declare(strict_types=1);

/** View and search the menu (Feature 2 and 3). Only available items are shown to customers. */
function menu_index(): void
{
    $search = get_param('q');
    $category = get_param('category');

    $sql = 'SELECT menu_item_id, item_name, description, category, price
              FROM menu_item WHERE availability = true';
    $params = [];
    if ($search !== '') {
        $sql .= ' AND (item_name ILIKE ? OR description ILIKE ?)';
        $like = '%' . str_replace(['\\', '%', '_'], ['\\\\', '\\%', '\\_'], $search) . '%';
        $params[] = $like;
        $params[] = $like;
    }
    if ($category !== '') {
        $sql .= ' AND category = ?';
        $params[] = $category;
    }
    $sql .= ' ORDER BY category, item_name';

    $items = fetch_all($sql, $params);
    $categories = fetch_all('SELECT DISTINCT category FROM menu_item WHERE availability = true ORDER BY category');
    render('menu/index', compact('items', 'categories', 'search', 'category'));
}

function menu_show(): void
{
    $item = fetch_one(
        'SELECT menu_item_id, item_name, description, category, price, availability
           FROM menu_item WHERE menu_item_id = ?',
        [(int) get_param('id', '0')]
    );
    if ($item === null) {
        render('errors/404', [], 404);
        return;
    }
    render('menu/show', ['item' => $item]);
}
