<?php $title = 'My profile'; ?>
<h1>My profile</h1>
<?php foreach ($errors as $err): ?><div class="flash error"><?= e($err) ?></div><?php endforeach; ?>
<form method="post" action="/profile" class="form">
  <?= csrf_field() ?>
  <label>Email <input value="<?= e($customer['email']) ?>" disabled></label>
  <label>First name <input name="first_name" value="<?= e($customer['first_name']) ?>" maxlength="50" required></label>
  <label>Last name <input name="last_name" value="<?= e($customer['last_name']) ?>" maxlength="50" required></label>
  <label>Phone <input name="phone" value="<?= e($customer['phone']) ?>" maxlength="20" required></label>
  <label>New password (leave blank to keep the current one) <input type="password" name="new_password" minlength="8"></label>
  <button class="btn">Save changes</button>
</form>
