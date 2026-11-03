<?php $title = 'My reservations'; ?>
<h1>My reservations</h1>
<p><a class="btn" href="/reservations/new">Reserve a table</a></p>
<?php if (!$reservations): ?><div class="empty"><strong>No reservations yet.</strong><br>Pick a date and time to <a href="/reservations/new">reserve a table</a>.</div><?php else: ?>
<table class="table">
  <tr><th>Date</th><th>Time</th><th>Table</th><th>Guests</th><th>Status</th><th></th></tr>
  <?php foreach ($reservations as $r): ?>
    <tr>
      <td><?= e(dt($r['reservation_date'], 'M j, Y')) ?></td>
      <td><?= e(dt($r['reservation_time'], 'g:i A')) ?></td>
      <td>Table <?= (int) $r['table_number'] ?></td>
      <td><?= (int) $r['number_of_guests'] ?></td>
      <td><span class="badge <?= e($r['reservation_status']) ?>"><?= e(label($r['reservation_status'])) ?></span></td>
      <td>
        <?php if (in_array($r['reservation_status'], ['pending', 'confirmed'], true)): ?>
          <form method="post" action="/reservations/cancel" class="inline" onsubmit="return confirm('Cancel this reservation?');">
            <?= csrf_field() ?><input type="hidden" name="reservation_id" value="<?= (int) $r['reservation_id'] ?>">
            <button class="btn small danger">Cancel</button>
          </form>
        <?php endif; ?>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
<?php endif; ?>
