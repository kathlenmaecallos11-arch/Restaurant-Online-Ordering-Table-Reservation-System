<?php $title = $item['menu_item_id'] ? 'Edit menu item' : 'New menu item'; ?>
<h1><?= e($title) ?></h1>
<?php foreach ($errors as $err): ?><div class="flash error"><?= e($err) ?></div><?php endforeach; ?>
<form method="post" action="/admin/menu/save" class="form">
  <?= csrf_field() ?>
  <input type="hidden" name="menu_item_id" value="<?= (int) $item['menu_item_id'] ?>">
  <label>Name <input name="item_name" value="<?= e($item['item_name']) ?>" maxlength="100" required></label>
  <label>Category <input name="category" value="<?= e($item['category']) ?>" maxlength="50" required></label>
  <label>Description <textarea name="description" rows="3"><?= e($item['description']) ?></textarea></label>
  <label>Price (PHP) <input type="number" name="price" step="0.01" min="0" value="<?= e($item['price']) ?>" required></label>
  <label class="check"><input type="checkbox" name="availability" value="1" <?= to_bool($item['availability']) ? 'checked' : '' ?>> Available for ordering</label>
  <button class="btn">Save</button> <a href="/admin/menu">Cancel</a>
</form>
