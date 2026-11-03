/* Mesa preview: a working DEMO of the interface. Data lives only in this browser (localStorage).
   The real system (PHP + PostgreSQL) is in ../app; see ../docs/DATABASE_CONNECTION.md. */
(function () {
  'use strict';
  var KEY = 'mesa_preview_v1';
  var SLOTS = ['10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00'];
  var METHODS = ['cash','card','gcash','bank_transfer'];
  var STATUSES = ['pending','confirmed','preparing','ready','completed','cancelled'];
  var MENU = [
    [1,'Lumpiang Shanghai','Crispy pork spring rolls with sweet chili dip (8 pcs).','Appetizer',180,true],
    [2,'Calamares','Fried squid rings with spiced vinegar.','Appetizer',220,true],
    [3,'Chicken Adobo','Chicken braised in soy sauce, vinegar and garlic.','Main Course',280,true],
    [4,'Sinigang na Baboy','Pork in tamarind broth with vegetables.','Main Course',320,true],
    [5,'Kare-Kare','Oxtail and vegetables in peanut sauce with bagoong.','Main Course',420,true],
    [6,'Pancit Canton','Stir-fried noodles with vegetables and pork.','Main Course',250,true],
    [7,'Halo-Halo','Shaved ice dessert with sweet beans, fruits and leche flan.','Dessert',150,true],
    [8,'Leche Flan','Creamy caramel custard.','Dessert',120,false],
    [9,'Iced Tea','House-blend iced tea (glass).','Beverage',80,true],
    [10,'Buko Juice','Fresh young coconut juice.','Beverage',100,true]
  ].map(function (m) { return { id: m[0], name: m[1], desc: m[2], cat: m[3], price: m[4], on: m[5] }; });
  var TABLES = [[1,2],[2,2],[3,4],[4,4],[5,4],[6,6],[7,8]].map(function (t) { return { n: t[0], seats: t[1] }; });

  function seed() {
    return {
      user: null, cart: {}, nextOrder: 7, nextRes: 8,
      orders: [
        { id: 5, who: 'Liza Ramos',   when: 'Nov 3, 2026 9:12 AM',  status: 'pending',   pay: 'pending',   total: 360,  mine: false },
        { id: 4, who: 'Pedro Garcia', when: 'Nov 2, 2026 6:40 PM',  status: 'preparing', pay: 'pending',   total: 1180, mine: false },
        { id: 3, who: 'Ana Reyes',    when: 'Oct 31, 2026 7:05 PM', status: 'completed', pay: 'paid',      total: 570,  mine: false },
        { id: 6, who: 'Maria Santos', when: 'Nov 1, 2026 12:30 PM', status: 'cancelled', pay: 'cancelled', total: 640,  mine: false }
      ],
      res: []
    };
  }
  var S;
  try { S = JSON.parse(localStorage.getItem(KEY)) || seed(); } catch (e) { S = seed(); }
  function save() { try { localStorage.setItem(KEY, JSON.stringify(S)); } catch (e) {} }

  function esc(v) { return String(v).replace(/[&<>"']/g, function (c) { return { '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]; }); }
  function money(v) { return 'PHP ' + Number(v).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }); }
  function label(s) { return s.replace(/_/g, ' ').replace(/\b\w/g, function (c) { return c.toUpperCase(); }); }
  function t12(t) { var h = +t.slice(0, 2); return ((h + 11) % 12 + 1) + ':' + t.slice(3) + ' ' + (h < 12 ? 'AM' : 'PM'); }
  function qs(name) { return new URLSearchParams(location.search).get(name) || ''; }
  function $(s, r) { return (r || document).querySelector(s); }
  function $$(s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); }
  function find(id) { return MENU.filter(function (m) { return m.id === id; })[0]; }
  function cartCount() { return Object.keys(S.cart).reduce(function (a, k) { return a + S.cart[k]; }, 0); }
  function cartTotal() { return Object.keys(S.cart).reduce(function (a, k) { return a + S.cart[k] * find(+k).price; }, 0); }

  function toast(msg, type) {
    var d = document.createElement('div');
    d.className = 'flash ' + (type || 'success'); d.setAttribute('role', 'status');
    d.textContent = msg;
    var host = $('#main') || document.body;
    host.insertBefore(d, host.firstChild);
    setTimeout(function () { if (d.parentNode) d.parentNode.removeChild(d); }, 4000);
    window.scrollTo(0, 0);
  }
  function flashNext(msg, type) { sessionStorage.setItem('mesa_flash', JSON.stringify([msg, type || 'success'])); }
  function needLogin() { if (!S.user) { flashNext('Log in or register to continue.', 'error'); sessionStorage.setItem('mesa_next', location.pathname.split('/').pop() + location.search); location.href = 'login.html'; return true; } return false; }

  /* ---------- shared header ---------- */
  var page = location.pathname.split('/').pop() || 'index.html';
  var admin = /^admin/.test(page);
  function nav(href, text) { return '<a href="' + href + '"' + (page === href ? ' aria-current="page"' : '') + '>' + text + '</a>'; }
  function chrome() {
    var head;
    if (admin) {
      head = '<aside class="side"><a class="brand" href="admin.html">Mesa</a><nav aria-label="Staff">' +
        nav('admin.html', 'Today') + nav('admin-orders.html', 'Orders') + '<a href="menu.html">View customer site</a></nav>' +
        '<div class="me">Alicia Mendoza<br><span>Administrator</span><form id="logout"><button class="link">Log out</button></form></div></aside>';
      return head;
    }
    head = '<header class="site-header"><div class="bar"><a class="brand" href="index.html">Mesa<small>order &amp; reserve</small></a>' +
      '<nav class="main-nav" aria-label="Main">' + nav('menu.html', 'Menu') + nav('reserve.html', 'Reserve a table') +
      (S.user ? nav('orders.html', 'My orders') + nav('reservations.html', 'My reservations') : '') + '</nav>' +
      '<div class="account"><a href="cart.html">Your order (' + cartCount() + ')</a>' +
      (S.user ? '<a href="login.html">' + esc(S.user) + '</a><form id="logout"><button class="link">Log out</button></form>'
              : '<a href="login.html">Log in</a><a href="login.html#register">Register</a><a href="admin.html">Staff</a>') +
      '</div></div></header>';
    return head;
  }
  var body = $('#app');
  var inner = body.innerHTML;
  var footer = '<footer class="site-footer">COMP 018 Database Administration project &middot; Group Binary Sisters &middot; Interface demo (data stays in this browser)</footer>';
  if (admin) { body.innerHTML = '<div class="shell">' + chrome() + '<div class="work" id="main">' + inner + '</div></div>'; }
  else { body.innerHTML = chrome() + (page === 'index.html' ? inner : '<main class="container" id="main">' + inner + '</main>') + footer; }
  var pending = sessionStorage.getItem('mesa_flash');
  if (pending) { sessionStorage.removeItem('mesa_flash'); pending = JSON.parse(pending); setTimeout(function () { toast(pending[0], pending[1]); }, 0); }
  var lo = $('#logout');
  if (lo) lo.addEventListener('submit', function (e) { e.preventDefault(); S.user = null; S.cart = {}; save(); flashNext('You have been logged out.'); location.href = 'index.html'; });

  /* ---------- pages ---------- */
  var pages = {};

  pages['index.html'] = function () {
    var d = new Date(Date.now() + 864e5), iso = d.toISOString().slice(0, 10);
    var f = $('#find'); f.date.value = iso; f.date.min = new Date().toISOString().slice(0, 10);
    f.time.innerHTML = SLOTS.map(function (s) { return '<option value="' + s + '"' + (s === '18:00' ? ' selected' : '') + '>' + t12(s) + '</option>'; }).join('');
    f.addEventListener('submit', function (e) { e.preventDefault(); location.href = 'reserve.html?date=' + f.date.value + '&time=' + f.time.value + '&guests=' + f.guests.value; });
    $('#featured').innerHTML = MENU.filter(function (m) { return [3, 4, 7, 1].indexOf(m.id) > -1; }).map(function (m) {
      return '<li class="dish"><div><div class="dish-head"><a class="dish-name" href="menu.html?q=' + encodeURIComponent(m.name) + '">' + esc(m.name) + '</a><span class="leader" aria-hidden="true"></span><span class="price">' + money(m.price) + '</span></div><p class="dish-desc">' + esc(m.desc) + '</p></div></li>';
    }).join('');
  };

  pages['menu.html'] = function () {
    var q = qs('q').toLowerCase(), cat = qs('category');
    var cats = []; MENU.forEach(function (m) { if (m.on && cats.indexOf(m.cat) < 0) cats.push(m.cat); });
    var link = function (c) { var p = []; if (q) p.push('q=' + encodeURIComponent(qs('q'))); if (c) p.push('category=' + encodeURIComponent(c)); return 'menu.html' + (p.length ? '?' + p.join('&') : ''); };
    $('#q').value = qs('q');
    $('#chips').innerHTML = '<li><a href="' + link('') + '"' + (!cat ? ' aria-current="true"' : '') + '>All</a></li>' +
      cats.map(function (c) { return '<li><a href="' + link(c) + '"' + (c === cat ? ' aria-current="true"' : '') + '>' + esc(c) + '</a></li>'; }).join('');
    $('#search').addEventListener('submit', function (e) { e.preventDefault(); var p = []; if ($('#q').value.trim()) p.push('q=' + encodeURIComponent($('#q').value.trim())); if (cat) p.push('category=' + encodeURIComponent(cat)); location.href = 'menu.html' + (p.length ? '?' + p.join('&') : ''); });
    var items = MENU.filter(function (m) { return m.on && (!cat || m.cat === cat) && (!q || (m.name + ' ' + m.desc).toLowerCase().indexOf(q) > -1); });
    if (!items.length) { $('#board').innerHTML = '<div class="empty"><strong>No dishes match your search.</strong><br>Clear the search or pick another category.</div>'; return; }
    var groups = {}; items.forEach(function (m) { (groups[m.cat] = groups[m.cat] || []).push(m); });
    $('#board').innerHTML = Object.keys(groups).map(function (c) {
      return '<section class="course"><h2>' + esc(c) + ' <span>' + groups[c].length + (groups[c].length === 1 ? ' dish' : ' dishes') + '</span></h2><ul class="dishes">' +
        groups[c].map(function (m) {
          return '<li class="dish"><div><div class="dish-head"><span class="dish-name">' + esc(m.name) + '</span><span class="leader" aria-hidden="true"></span><span class="price">' + money(m.price) + '</span></div><p class="dish-desc">' + esc(m.desc) + '</p></div>' +
            '<form class="add" data-id="' + m.id + '"><label class="sr-only" for="qty-' + m.id + '">Quantity of ' + esc(m.name) + '</label><input id="qty-' + m.id + '" class="qty" type="number" name="quantity" value="1" min="1" max="20"><button class="btn small">Add to order</button></form></li>';
        }).join('') + '</ul></section>';
    }).join('');
    $$('form.add').forEach(function (f) {
      f.addEventListener('submit', function (e) {
        e.preventDefault();
        var id = +f.dataset.id, n = Math.max(1, Math.min(20, parseInt(f.quantity.value, 10) || 1));
        S.cart[id] = Math.min(20, (S.cart[id] || 0) + n); save();
        flashNext('Added to your order.'); location.href = 'cart.html';
      });
    });
  };

  pages['cart.html'] = function () {
    var ids = Object.keys(S.cart);
    var box = $('#cart');
    if (!ids.length) { box.innerHTML = '<div class="empty"><strong>Your order is empty.</strong><br>Add a few dishes from the <a href="menu.html">menu</a> to get started.</div>'; return; }
    box.innerHTML = '<div class="split"><form id="upd"><table class="table"><tr><th>Dish</th><th>Price</th><th>Quantity</th><th class="right">Total</th><th></th></tr>' +
      ids.map(function (k) { var m = find(+k); return '<tr><td>' + esc(m.name) + '</td><td>' + money(m.price) + '</td><td><label class="sr-only" for="c' + k + '">Quantity of ' + esc(m.name) + '</label><input id="c' + k + '" type="number" class="qty" data-id="' + k + '" value="' + S.cart[k] + '" min="0" max="20"></td><td class="right">' + money(m.price * S.cart[k]) + '</td><td><button type="button" class="link danger" data-remove="' + k + '">Remove</button></td></tr>'; }).join('') +
      '</table><p class="muted">Set a quantity to 0 to remove a dish.</p><button class="btn secondary">Update quantities</button></form>' +
      '<aside class="panel"><h2>Checkout</h2><div class="sum"><span>Total</span><span>' + money(cartTotal()) + '</span></div>' +
      (S.user ? '<form id="pay"><fieldset><legend>How will you pay?</legend><div class="choices">' + METHODS.map(function (m, i) { return '<label><input type="radio" name="payment_method" value="' + m + '"' + (i === 0 ? ' checked' : '') + '><span>' + label(m) + '</span></label>'; }).join('') + '</div></fieldset><button class="btn" style="width:100%">Place order</button></form>'
                : '<p>Log in or create an account to place this order. Your dishes stay in your order.</p><p><a class="btn" href="login.html">Log in</a> <a class="btn secondary" href="login.html#register">Register</a></p>') +
      '<p style="margin-top:1rem"><button type="button" class="link danger" id="clear">Empty my order</button></p></aside></div>';
    $('#upd').addEventListener('submit', function (e) {
      e.preventDefault();
      $$('input[data-id]', e.target).forEach(function (i) { var n = parseInt(i.value, 10) || 0; if (n <= 0) delete S.cart[i.dataset.id]; else S.cart[i.dataset.id] = Math.min(20, n); });
      save(); flashNext('Cart updated.'); location.reload();
    });
    $$('[data-remove]').forEach(function (b) { b.addEventListener('click', function () { delete S.cart[b.dataset.remove]; save(); flashNext('Dish removed from your order.'); location.reload(); }); });
    $('#clear').addEventListener('click', function () { S.cart = {}; save(); location.reload(); });
    var pay = $('#pay');
    if (pay) pay.addEventListener('submit', function (e) {
      e.preventDefault();
      var id = S.nextOrder++;
      S.orders.unshift({ id: id, who: S.user, when: new Date().toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit' }), status: 'pending', pay: 'pending', method: pay.payment_method.value, total: cartTotal(), mine: true,
        lines: Object.keys(S.cart).map(function (k) { var m = find(+k); return { name: m.name, qty: S.cart[k], price: m.price }; }) });
      S.cart = {}; save(); flashNext('Order #' + id + ' placed. Staff will confirm it shortly.'); location.href = 'orders.html?id=' + id;
    });
  };

  pages['login.html'] = function () {
    var reg = location.hash === '#register';
    $('#title').textContent = reg ? 'Create an account' : 'Log in';
    $('#regfields').style.display = reg ? '' : 'none';
    $('#switch').innerHTML = reg ? 'Already registered? <a href="login.html">Log in</a>.' : 'New here? <a href="login.html#register">Create an account</a>. Restaurant staff: <a href="admin.html">log in here</a>.';
    window.addEventListener('hashchange', function () { location.reload(); });
    $('#loginform').addEventListener('submit', function (e) {
      e.preventDefault();
      var f = e.target, name = reg ? f.first_name.value.trim() : (f.email.value.split('@')[0].split('.')[0] || 'Guest');
      S.user = name.charAt(0).toUpperCase() + name.slice(1); save();
      flashNext(reg ? 'Welcome! Your account has been created.' : 'You are logged in.');
      var next = sessionStorage.getItem('mesa_next'); sessionStorage.removeItem('mesa_next');
      location.href = next || 'menu.html';
    });
  };

  pages['reserve.html'] = function () {
    var f = $('#rform'), date = qs('date'), time = qs('time'), guests = parseInt(qs('guests'), 10) || 2;
    f.date.value = date || new Date(Date.now() + 864e5).toISOString().slice(0, 10); f.date.min = new Date().toISOString().slice(0, 10);
    f.guests.value = guests;
    $('#slots').innerHTML = SLOTS.map(function (s) { return '<label><input type="radio" name="time" value="' + s + '"' + (s === time ? ' checked' : '') + ' required><span>' + t12(s) + '</span></label>'; }).join('');
    f.addEventListener('submit', function (e) { e.preventDefault(); location.href = 'reserve.html?date=' + f.date.value + '&time=' + f.time.value + '&guests=' + f.guests.value; });
    if (!date || !time) return;
    var start = new Date(date + 'T' + time + ':00');
    if (start <= new Date()) { $('#result').innerHTML = '<div class="flash error">Choose a date and time in the future.</div>'; return; }
    var free = TABLES.filter(function (t) {
      if (t.seats < guests) return false;
      return !S.res.some(function (r) { return r.table === t.n && r.status !== 'cancelled' && Math.abs(new Date(r.date + 'T' + r.time + ':00') - start) < 2 * 36e5; });
    });
    var h = '<h2>Free tables on ' + start.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' }) + ' at ' + t12(time) + '</h2>';
    h += free.length ? '<ul class="slots">' + free.map(function (t) { var pips = ''; for (var i = 0; i < Math.min(10, t.seats); i++) pips += '<i></i>'; return '<li class="slot"><span class="t">Table ' + t.n + '</span><span class="pips">' + pips + '<b>' + t.seats + ' seats</b></span><form class="inline" data-table="' + t.n + '"><button class="btn small">Reserve this table</button></form></li>'; }).join('') + '</ul>'
      : '<div class="empty"><strong>No table is free for ' + guests + ' guests at that time.</strong><br>Try another time slot or a different date.</div>';
    $('#result').innerHTML = h;
    $$('form[data-table]').forEach(function (tf) {
      tf.addEventListener('submit', function (e) {
        e.preventDefault(); if (needLogin()) return;
        S.res.push({ id: S.nextRes++, date: date, time: time, table: +tf.dataset.table, guests: guests, status: 'confirmed' }); save();
        flashNext('Your table is reserved. See you on ' + start.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) + ' at ' + t12(time) + '!'); location.href = 'reservations.html';
      });
    });
  };

  pages['orders.html'] = function () {
    var mine = S.orders.filter(function (o) { return o.mine; }), id = +qs('id');
    if (needLogin()) return;
    if (id) {
      var o = mine.filter(function (x) { return x.id === id; })[0];
      if (!o) { $('#box').innerHTML = '<p>Order not found.</p><p><a href="orders.html">Back to my orders</a></p>'; return; }
      $('#box').innerHTML = '<h1>Order #' + o.id + '</h1><p>Placed ' + esc(o.when) + ' &middot; Status: <span class="badge ' + o.status + '">' + label(o.status) + '</span> &middot; Payment: ' + label(o.method || 'cash') + ' / ' + label(o.pay) + '</p>' +
        '<table class="table"><tr><th>Item</th><th>Qty</th><th>Unit price</th><th>Subtotal</th></tr>' + (o.lines || []).map(function (l) { return '<tr><td>' + esc(l.name) + '</td><td>' + l.qty + '</td><td>' + money(l.price) + '</td><td>' + money(l.qty * l.price) + '</td></tr>'; }).join('') +
        '<tr class="total"><th colspan="3" class="right">Total</th><th class="right">' + money(o.total) + '</th></tr></table>' +
        (o.status === 'pending' ? '<form id="cancel"><button class="btn danger">Cancel order</button></form>' : '') + '<p><a href="orders.html">Back to my orders</a></p>';
      var c = $('#cancel'); if (c) c.addEventListener('submit', function (e) { e.preventDefault(); if (!confirm('Cancel this order?')) return; o.status = 'cancelled'; o.pay = 'cancelled'; save(); flashNext('Order #' + o.id + ' was cancelled.'); location.reload(); });
      return;
    }
    $('#box').innerHTML = '<h1>My orders</h1>' + (!mine.length ? '<div class="empty"><strong>No orders yet.</strong><br>Browse the <a href="menu.html">menu</a> and place your first order.</div>' :
      '<table class="table"><tr><th>Order</th><th>Date</th><th>Status</th><th>Payment</th><th>Total</th></tr>' + mine.map(function (o) { return '<tr><td><a href="orders.html?id=' + o.id + '">#' + o.id + '</a></td><td>' + esc(o.when) + '</td><td><span class="badge ' + o.status + '">' + label(o.status) + '</span></td><td>' + label(o.pay) + '</td><td>' + money(o.total) + '</td></tr>'; }).join('') + '</table>');
  };

  pages['reservations.html'] = function () {
    if (needLogin()) return;
    var h = '<h1>My reservations</h1><p><a class="btn" href="reserve.html">Reserve a table</a></p>';
    h += !S.res.length ? '<div class="empty"><strong>No reservations yet.</strong><br>Pick a date and time to <a href="reserve.html">reserve a table</a>.</div>' :
      '<table class="table"><tr><th>Date</th><th>Time</th><th>Table</th><th>Guests</th><th>Status</th><th></th></tr>' + S.res.map(function (r) {
        return '<tr><td>' + new Date(r.date + 'T00:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) + '</td><td>' + t12(r.time) + '</td><td>Table ' + r.table + '</td><td>' + r.guests + '</td><td><span class="badge ' + r.status + '">' + label(r.status) + '</span></td><td>' +
          (r.status === 'confirmed' || r.status === 'pending' ? '<button class="btn small danger" data-cancel="' + r.id + '">Cancel</button>' : '') + '</td></tr>'; }).join('') + '</table>';
    $('#box').innerHTML = h;
    $$('[data-cancel]').forEach(function (b) { b.addEventListener('click', function () { if (!confirm('Cancel this reservation?')) return; S.res.forEach(function (r) { if (r.id === +b.dataset.cancel) r.status = 'cancelled'; }); save(); flashNext('Reservation cancelled.'); location.reload(); }); });
  };

  function orderRows(list) {
    return list.map(function (o) { return '<tr><td>#' + o.id + '</td><td>' + esc(o.who) + '</td><td>' + esc(o.when) + '</td><td><span class="badge ' + o.status + '">' + label(o.status) + '</span></td><td>' + label(o.pay) + '</td><td class="right">' + money(o.total) + '</td></tr>'; }).join('');
  }
  pages['admin.html'] = function () {
    var pend = S.orders.filter(function (o) { return o.status === 'pending'; }).length;
    var unpaid = S.orders.filter(function (o) { return o.pay === 'pending'; }).length;
    $('#n1').textContent = pend; $('#n3').textContent = unpaid;
    $('#recent').innerHTML = S.orders.slice(0, 5).map(function (o) { return '<tr><td><a href="admin-orders.html">#' + o.id + '</a></td><td>' + esc(o.who) + '</td><td>' + esc(o.when) + '</td><td><span class="badge ' + o.status + '">' + label(o.status) + '</span></td><td class="right">' + money(o.total) + '</td></tr>'; }).join('');
  };
  pages['admin-orders.html'] = function () {
    var sel = $('#status'); sel.innerHTML = '<option value="">All statuses</option>' + STATUSES.map(function (s) { return '<option value="' + s + '">' + label(s) + '</option>'; }).join('');
    sel.value = qs('status');
    $('#filter').addEventListener('submit', function (e) { e.preventDefault(); location.href = 'admin-orders.html' + (sel.value ? '?status=' + sel.value : ''); });
    var list = S.orders.filter(function (o) { return !sel.value || o.status === sel.value; });
    $('#rows').innerHTML = list.map(function (o) {
      return '<tr><td>#' + o.id + '</td><td>' + esc(o.who) + '</td><td>' + esc(o.when) + '</td><td><form class="inline" data-order="' + o.id + '"><select name="s">' + STATUSES.map(function (s) { return '<option value="' + s + '"' + (s === o.status ? ' selected' : '') + '>' + label(s) + '</option>'; }).join('') + '</select> <button class="btn small">Set</button></form></td><td>' + label(o.pay) + '</td><td class="right">' + money(o.total) + '</td></tr>'; }).join('');
    $$('form[data-order]').forEach(function (f) {
      f.addEventListener('submit', function (e) {
        e.preventDefault();
        S.orders.forEach(function (o) { if (o.id === +f.dataset.order) { o.status = f.s.value; if (o.status === 'cancelled' && o.pay === 'pending') o.pay = 'cancelled'; } });
        save(); flashNext('Order #' + f.dataset.order + ' is now ' + label(f.s.value) + '.'); location.reload();
      });
    });
  };

  if (pages[page]) pages[page]();
})();
