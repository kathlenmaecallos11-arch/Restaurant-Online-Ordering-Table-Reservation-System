<?php $title = $table['table_id'] ? 'Edit table' : 'New table'; ?>
<h1><?= e($title) ?></h1>
<?php foreach ($errors as $err): ?><div class="flash error"><?= e($err) ?></div><?php endforeach; ?>
<form method="post" action="/admin/tables/save" class="form">
  <?= csrf_field() ?>
  <input type="hidden" name="table_id" value="<?= (int) $table['table_id'] ?>">
  <label>Table number <input type="number" name="table_number" min="1" value="<?= e($table['table_number']) ?>" required></label>
  <label>Capacity (seats) <input type="number" name="capacity" min="1" max="50" value="<?= e($table['capacity']) ?>" required></label>
  <label>Status
    <select name="status">
      <?php foreach (TABLE_STATUSES as $s): ?><option value="<?= e($s) ?>" <?= $s === $table['status'] ? 'selected' : '' ?>><?= e(label($s)) ?></option><?php endforeach; ?>
    </select>
  </label>
  <button class="btn">Save</button> <a href="/admin/tables">Cancel</a>
</form>
