<?php $title = 'Log in'; ?>
<h1>Log in</h1>
<?php if (!empty($error)): ?><div class="flash error"><?= e($error) ?></div><?php endif; ?>
<form method="post" action="/login" class="form">
  <?= csrf_field() ?>
  <label>Email <input type="email" name="email" value="<?= e($email) ?>" required></label>
  <label>Password <input type="password" name="password" required></label>
  <div><button class="btn">Log in</button></div>
</form>
<p class="muted">New here? <a href="/register">Create an account</a>. Restaurant staff: <a href="/staff/login">log in here</a>.</p>
