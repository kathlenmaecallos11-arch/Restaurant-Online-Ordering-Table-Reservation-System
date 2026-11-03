<?php $title = 'Staff log in'; ?>
<h1>Staff / administrator log in</h1>
<?php if (!empty($error)): ?><div class="flash error"><?= e($error) ?></div><?php endif; ?>
<form method="post" action="/staff/login" class="form">
  <?= csrf_field() ?>
  <label>Email <input type="email" name="email" value="<?= e($email) ?>" required></label>
  <label>Password <input type="password" name="password" required></label>
  <div><button class="btn">Log in</button></div>
</form>
