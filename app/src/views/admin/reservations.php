<?php $title = 'Manage reservations'; ?>
<h1>Reservations</h1>
<form method="get" action="/admin/reservations" class="filters">
  <input type="date" name="date" value="<?= e($date) ?>">
  <button class="btn small">Filter by date</button> <a href="/admin/reservations">Clear</a>
</form>
<table class="table">
  <tr><th>Date</th><th>Time</th><th>Table</th><th>Guests</th><th>Customer</th><th>Status</th><th></th></tr>
  <?php foreach ($reservations as $r): ?>
    <tr>
      <td><?= e(dt($r['reservation_date'], 'M j, Y')) ?></td>
      <td><?= e(dt($r['reservation_time'], 'g:i A')) ?></td>
      <td>Table <?= (int) $r['table_number'] ?></td>
      <td><?= (int) $r['number_of_guests'] ?></td>
      <td><?= e($r['first_name'] . ' ' . $r['last_name']) ?><br><span class="muted"><?= e($r['phone']) ?></span></td>
      <td>
        <form method="post" action="/admin/reservations/status" class="inline">
          <?= csrf_field() ?><input type="hidden" name="reservation_id" value="<?= (int) $r['reservation_id'] ?>">
          <select name="reservation_status">
            <?php foreach (RESERVATION_STATUSES as $s): ?><option value="<?= e($s) ?>" <?= $s === $r['reservation_status'] ? 'selected' : '' ?>><?= e(label($s)) ?></option><?php endforeach; ?>
          </select>
          <button class="btn small">Set</button>
        </form>
      </td>
      <td>
        <?php if ($staff['role'] === 'admin'): ?>
          <form method="post" action="/admin/reservations/delete" class="inline" onsubmit="return confirm('Delete this reservation?');">
            <?= csrf_field() ?><input type="hidden" name="reservation_id" value="<?= (int) $r['reservation_id'] ?>">
            <button class="link danger">Delete</button>
          </form>
        <?php endif; ?>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
