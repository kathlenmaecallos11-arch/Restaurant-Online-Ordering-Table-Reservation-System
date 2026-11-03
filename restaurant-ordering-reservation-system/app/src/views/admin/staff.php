<?php $title = 'Staff accounts'; ?>
<h1>Staff accounts</h1>
<p><a class="btn" href="/admin/staff/edit">Add staff account</a></p>
<table class="table">
  <tr><th>Name</th><th>Email</th><th>Role</th><th></th></tr>
  <?php foreach ($members as $m): ?>
    <tr>
      <td><?= e($m['first_name'] . ' ' . $m['last_name']) ?></td><td><?= e($m['email']) ?></td><td><?= e($m['role']) ?></td>
      <td>
        <a href="/admin/staff/edit?id=<?= (int) $m['staff_id'] ?>">Edit</a>
        <?php if ((int) $m['staff_id'] !== (int) $staff['staff_id']): ?>
          <form method="post" action="/admin/staff/delete" class="inline" onsubmit="return confirm('Delete this account?');">
            <?= csrf_field() ?><input type="hidden" name="staff_id" value="<?= (int) $m['staff_id'] ?>">
            <button class="link danger">Delete</button>
          </form>
        <?php endif; ?>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
