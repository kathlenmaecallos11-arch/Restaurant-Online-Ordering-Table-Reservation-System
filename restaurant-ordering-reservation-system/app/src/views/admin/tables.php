<?php $title = 'Manage tables'; ?>
<h1>Restaurant tables</h1>
<?php if ($staff['role'] === 'admin'): ?><p><a class="btn" href="/admin/tables/edit">Add table</a></p><?php endif; ?>
<table class="table">
  <tr><th>Table</th><th>Seats</th><th>Status</th><th></th></tr>
  <?php foreach ($tables as $t): ?>
    <tr>
      <td>Table <?= (int) $t['table_number'] ?></td><td><?= (int) $t['capacity'] ?></td>
      <td>
        <form method="post" action="/admin/tables/status" class="inline">
          <?= csrf_field() ?><input type="hidden" name="table_id" value="<?= (int) $t['table_id'] ?>">
          <select name="status" aria-label="Status of table <?= (int) $t['table_number'] ?>">
            <?php foreach (TABLE_STATUSES as $s): ?><option value="<?= e($s) ?>" <?= $s === $t['status'] ? 'selected' : '' ?>><?= e(label($s)) ?></option><?php endforeach; ?>
          </select>
          <button class="btn small">Set</button>
        </form>
      </td>
      <td>
        <?php if ($staff['role'] === 'admin'): ?>
          <a href="/admin/tables/edit?id=<?= (int) $t['table_id'] ?>">Edit</a>
          <form method="post" action="/admin/tables/delete" class="inline" onsubmit="return confirm('Delete this table?');">
            <?= csrf_field() ?><input type="hidden" name="table_id" value="<?= (int) $t['table_id'] ?>">
            <button class="link danger">Delete</button>
          </form>
        <?php endif; ?>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
