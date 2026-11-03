<?php $title = 'Register'; ?>
<h1>Create an account</h1>
<?php foreach ($errors as $err): ?><div class="flash error"><?= e($err) ?></div><?php endforeach; ?>
<form method="post" action="/register" class="form">
  <?= csrf_field() ?>
  <label>First name <input name="first_name" value="<?= e($old['first_name'] ?? '') ?>" maxlength="50" required></label>
  <label>Last name <input name="last_name" value="<?= e($old['last_name'] ?? '') ?>" maxlength="50" required></label>
  <label>Email <input type="email" name="email" value="<?= e($old['email'] ?? '') ?>" maxlength="100" required></label>
  <label>Phone <input name="phone" value="<?= e($old['phone'] ?? '') ?>" maxlength="20" required></label>
  <label>Password (min. 8 characters) <input type="password" name="password" minlength="8" required></label>
  <label>Confirm password <input type="password" name="password_confirm" minlength="8" required></label>
  <div><button class="btn">Create account</button></div>
</form>
