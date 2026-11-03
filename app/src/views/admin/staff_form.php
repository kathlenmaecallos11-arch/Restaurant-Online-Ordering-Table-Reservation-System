<?php $title = $member['staff_id'] ? 'Edit staff account' : 'New staff account'; ?>
<h1><?= e($title) ?></h1>
<?php foreach ($errors as $err): ?><div class="flash error"><?= e($err) ?></div><?php endforeach; ?>
<form method="post" action="/admin/staff/save" class="form">
  <?= csrf_field() ?>
  <input type="hidden" name="staff_id" value="<?= (int) $member['staff_id'] ?>">
  <label>First name <input name="first_name" value="<?= e($member['first_name']) ?>" maxlength="50" required></label>
  <label>Last name <input name="last_name" value="<?= e($member['last_name']) ?>" maxlength="50" required></label>
  <label>Email <input type="email" name="email" value="<?= e($member['email']) ?>" maxlength="100" required></label>
  <label>Role
    <select name="role">
      <?php foreach (STAFF_ROLES as $r): ?><option value="<?= e($r) ?>" <?= $r === $member['role'] ? 'selected' : '' ?>><?= e($r) ?></option><?php endforeach; ?>
    </select>
  </label>
  <label>Password <?= $member['staff_id'] ? '(leave blank to keep the current one)' : '(min. 8 characters)' ?> <input type="password" name="password" minlength="8" <?= $member['staff_id'] ? '' : 'required' ?>></label>
  <button class="btn">Save</button> <a href="/admin/staff">Cancel</a>
</form>
