<?php $title = 'Manage menu'; ?>
<h1>Manage menu</h1>
<?php if ($staff['role'] === 'admin'): ?><p><a class="btn" href="/admin/menu/edit">Add menu item</a></p><?php endif; ?>
<table class="table">
  <tr><th>Item</th><th>Category</th><th>Price</th><th>Available</th><th></th></tr>
  <?php foreach ($items as $i): ?>
    <tr>
      <td><?= e($i['item_name']) ?></td><td><?= e($i['category']) ?></td><td><?= e(money($i['price'])) ?></td>
      <td>
        <form method="post" action="/admin/menu/availability" class="inline">
          <?= csrf_field() ?><input type="hidden" name="menu_item_id" value="<?= (int) $i['menu_item_id'] ?>">
          <button class="btn small <?= to_bool($i['availability']) ? '' : 'secondary' ?>"><?= to_bool($i['availability']) ? 'Yes' : 'No' ?></button>
        </form>
      </td>
      <td>
        <?php if ($staff['role'] === 'admin'): ?>
          <a href="/admin/menu/edit?id=<?= (int) $i['menu_item_id'] ?>">Edit</a>
          <form method="post" action="/admin/menu/delete" class="inline" onsubmit="return confirm('Delete this menu item?');">
            <?= csrf_field() ?><input type="hidden" name="menu_item_id" value="<?= (int) $i['menu_item_id'] ?>">
            <button class="link danger">Delete</button>
          </form>
        <?php endif; ?>
      </td>
    </tr>
  <?php endforeach; ?>
</table>
