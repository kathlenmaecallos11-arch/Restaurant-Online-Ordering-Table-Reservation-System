/* Mesa preview: a working DEMO of the interface. */
(function () {
  'use strict';
  var KEY = 'mesa_preview_v2';
  var SLOTS = ['10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00'];
  var METHODS = ['cash','card','gcash','bank_transfer'];
  var STATUSES = ['pending','confirmed','preparing','ready','completed','cancelled'];
  var MENU = [
    [1,"Lumpiang Shanghai","Crispy pork spring rolls served with sweet chili sauce.","Appetizer",150,true],
    [2,"Calamares","Golden fried squid rings with garlic-vinegar dip.","Appetizer",220,true],
    [3,"Sisig Nachos","Tortilla chips topped with pork sisig and cheese sauce.","Appetizer",240,true],
    [4,"Tokwat Baboy","Fried tofu and pork in soy-vinegar dressing.","Appetizer",160,true],
    [5,"Chicharon Bulaklak","Crispy ruffled pork fat with spiced vinegar.","Appetizer",260,true],
    [6,"Fresh Lumpia","Fresh vegetable roll with peanut garlic sauce.","Appetizer",140,true],
    [7,"Garlic Mushrooms","Sauteed button mushrooms in garlic butter.","Appetizer",180,true],
    [8,"Cheesy Dynamite","Chili stuffed with cheese, wrapped and fried.","Appetizer",170,true],
    [9,"Kinilaw na Tanigue","Fresh tuna cured in vinegar, ginger and chili.","Appetizer",280,true],
    [10,"Buffalo Wings (6 pcs)","Spicy chicken wings with ranch dip.","Appetizer",230,false],
    [11,"Chicken Adobo","Chicken braised in soy sauce, vinegar and garlic.","Main Course",210,true],
    [12,"Pork Sinigang","Pork ribs in sour tamarind broth with vegetables.","Main Course",260,true],
    [13,"Beef Kare-Kare","Oxtail and beef in peanut sauce with bagoong.","Main Course",350,true],
    [14,"Crispy Pata","Deep-fried pork knuckle with liver sauce.","Main Course",620,true],
    [15,"Lechon Kawali","Deep-fried crispy pork belly with sauce.","Main Course",290,true],
    [16,"Sizzling Sisig","Chopped pork sisig on a hot plate with egg.","Main Course",270,true],
    [17,"Bicol Express","Pork in coconut milk with chili peppers.","Main Course",240,true],
    [18,"Beef Caldereta","Beef stew in tomato and liver sauce.","Main Course",330,true],
    [19,"Chicken Inasal","Grilled chicken marinated in calamansi and lemongrass.","Main Course",225,true],
    [20,"Grilled Liempo","Grilled pork belly with soy-calamansi dip.","Main Course",280,true],
    [21,"Bangus Sisig","Boneless milkfish sisig with onions and chili.","Main Course",250,true],
    [22,"Sweet and Sour Fish","Fried fish fillet in sweet and sour sauce.","Main Course",265,true],
    [23,"Pancit Canton","Stir-fried egg noodles with meat and vegetables.","Main Course",190,true],
    [24,"Pancit Palabok","Rice noodles with shrimp sauce and toppings.","Main Course",200,true],
    [25,"Beef Tapa Silog","Marinated beef tapa with garlic rice and egg.","Main Course",215,true],
    [26,"Longganisa Silog","Sweet native sausage with garlic rice and egg.","Main Course",185,true],
    [27,"Tuyo Silog","Dried herring with garlic rice and egg.","Main Course",165,true],
    [28,"Pork Sisig Rice Bowl","Sisig over steamed rice with fried egg.","Main Course",195,true],
    [29,"Seafood Kare-Kare","Mixed seafood in peanut sauce with vegetables.","Main Course",380,true],
    [30,"Shrimp in Garlic Butter","Large shrimp sauteed in garlic butter.","Main Course",360,true],
    [31,"Garlic Fried Rice","Fried rice with toasted garlic.","Main Course",60,true],
    [32,"Plain Rice","Steamed white rice.","Main Course",30,true],
    [33,"Halo-Halo","Shaved ice with sweet beans, fruits, leche flan and ube ice cream.","Dessert",150,true],
    [34,"Leche Flan","Creamy caramel custard.","Dessert",110,true],
    [35,"Turon with Ice Cream","Banana spring roll with caramel and vanilla ice cream.","Dessert",130,true],
    [36,"Mango Float","Layered graham, cream and ripe mango.","Dessert",140,true],
    [37,"Ube Halaya Cake","Soft ube cake with halaya topping.","Dessert",160,true],
    [38,"Buko Pandan","Young coconut and pandan jelly in sweet cream.","Dessert",120,true],
    [39,"Brownie Sundae","Warm chocolate brownie with vanilla ice cream.","Dessert",170,true],
    [40,"Sans Rival","Layered cashew meringue with buttercream.","Dessert",180,false],
    [41,"Iced Tea (Glass)","House-brewed iced tea.","Beverage",60,true],
    [42,"Calamansi Juice","Fresh calamansi juice, sweetened.","Beverage",70,true],
    [43,"Mango Shake","Blended ripe mango shake.","Beverage",100,true],
    [44,"Buko Juice","Fresh young coconut juice.","Beverage",80,true],
    [45,"Sagot Gulaman","Brown sugar drink with sago and gulaman.","Beverage",65,true],
    [46,"Brewed Coffee","Freshly brewed local coffee.","Beverage",90,true],
    [47,"Iced Latte","Espresso with cold milk over ice.","Beverage",125,true],
    [48,"Soda (Can)","Assorted canned soft drinks.","Beverage",55,true],
    [49,"Bottled Water","500 ml purified water.","Beverage",30,true],
    [50,"Pitcher of Iced Tea","Good for 4 persons.","Beverage",180,true]
  ].map(function (m) { return { id: m[0], name: m[1], desc: m[2], cat: m[3], price: m[4], on: m[5] }; });
  var TABLES = [[1,2,"available"],[2,2,"available"],[3,2,"occupied"],[4,2,"available"],[5,2,"available"],[6,4,"available"],[7,4,"available"],[8,4,"reserved"],[9,4,"available"],[10,4,"available"],[11,4,"available"],[12,4,"available"],[13,6,"available"],[14,6,"out_of_service"],[15,6,"available"],[16,6,"available"],[17,8,"occupied"],[18,8,"available"],[19,10,"available"],[20,12,"available"]].map(function (t) { return { n: t[0], seats: t[1], status: t[2] }; });

  function seed() {
    return {
      user: null, cart: {}, nextOrder: 61, nextRes: 51,
      orders: [
        [5,"Nour Kumar","Dec 27, 2023 1:10 PM","preparing","paid",885],
        [37,"Felix Moreau","Dec 21, 2023 6:20 PM","completed","paid",590],
        [42,"Rosa Davis","Dec 20, 2023 6:10 PM","completed","paid",750],
        [33,"Yusuf Hughes","Dec 20, 2023 4:15 PM","completed","paid",570],
        [7,"Ines Diaz","Dec 18, 2023 2:45 PM","completed","paid",240],
        [28,"Ines Diaz","Dec 15, 2023 1:15 PM","completed","paid",410],
        [38,"Maja Reyes","Nov 30, 2023 9:45 PM","completed","paid",620],
        [43,"Diego Shah","Nov 26, 2023 6:00 PM","completed","paid",945],
        [20,"Lena Schmidt","Nov 8, 2023 6:15 PM","completed","paid",410],
        [47,"Carlos Almeida","Nov 7, 2023 4:45 PM","completed","paid",360],
        [2,"Mia Hughes","Nov 2, 2023 8:00 PM","completed","paid",1000],
        [22,"James Castro","Oct 29, 2023 3:45 PM","completed","paid",945],
        [26,"Lina Nguyen","Oct 20, 2023 2:30 PM","cancelled","cancelled",170],
        [4,"Felix Moreau","Oct 5, 2023 10:10 AM","completed","paid",350],
        [29,"Felix Moreau","Oct 4, 2023 6:20 PM","completed","paid",590],
        [8,"Emma Hughes","Sep 30, 2023 5:00 PM","completed","paid",415],
        [19,"Hugo Novak","Sep 20, 2023 6:15 PM","cancelled","refunded",1080],
        [57,"Nour Kumar","Sep 20, 2023 4:20 PM","completed","paid",870],
        [60,"Lena Schmidt","Sep 7, 2023 2:40 PM","completed","paid",650],
        [15,"Tariq Ahmed","Sep 5, 2023 8:50 PM","ready","paid",1060],
        [40,"Emma Hughes","Aug 28, 2023 5:50 PM","completed","paid",1185],
        [17,"Andre Oliveira","Aug 21, 2023 6:15 PM","completed","paid",420],
        [13,"Nour Kumar","Jul 28, 2023 8:10 PM","pending","pending",740],
        [3,"Jack Singh","Jul 22, 2023 4:30 PM","completed","paid",730],
        [21,"Lena Schmidt","Jul 10, 2023 11:20 AM","completed","paid",435],
        [59,"Tariq Bauer","Jul 6, 2023 8:00 PM","completed","paid",650],
        [39,"Pedro Flores","Jul 5, 2023 9:15 PM","completed","paid",965],
        [54,"Nour Smith","Jun 17, 2023 3:15 PM","completed","paid",2075],
        [25,"Diego Lopez","Jun 9, 2023 8:50 PM","completed","paid",850],
        [1,"Ines Kumar","Jun 9, 2023 11:50 AM","ready","paid",710],
        [24,"Hugo Reyes","May 29, 2023 12:30 PM","completed","paid",530],
        [6,"Daniel Reyes","May 21, 2023 11:00 AM","completed","paid",850],
        [23,"Tariq Ahmed","May 8, 2023 3:45 PM","completed","paid",525],
        [41,"Felix Moreau","Apr 26, 2023 3:30 PM","pending","pending",60],
        [36,"Ravi Evans","Apr 25, 2023 5:45 PM","completed","paid",990],
        [56,"Zoe Smith","Apr 25, 2023 2:50 PM","cancelled","cancelled",870],
        [55,"Julia Zhang","Apr 24, 2023 4:30 PM","completed","paid",430],
        [32,"Lina Ahmed","Apr 22, 2023 6:45 PM","completed","paid",180],
        [44,"Rosa Davis","Apr 22, 2023 11:40 AM","completed","paid",295],
        [12,"Emma Hughes","Apr 21, 2023 6:00 PM","completed","paid",590],
        [16,"Rosa Davis","Apr 7, 2023 12:10 PM","completed","paid",740],
        [46,"Nour Shah","Apr 6, 2023 4:00 PM","pending","pending",335],
        [50,"Fatima Torres","Apr 3, 2023 12:20 PM","completed","paid",625],
        [9,"Pedro Flores","Apr 2, 2023 4:30 PM","ready","paid",820],
        [52,"Yara Ahmed","Mar 30, 2023 9:15 PM","preparing","paid",640],
        [53,"Maja Reyes","Mar 29, 2023 7:00 PM","completed","paid",860],
        [31,"Mateo Taylor","Mar 29, 2023 5:10 PM","completed","paid",415],
        [27,"Andre Oliveira","Mar 19, 2023 2:40 PM","cancelled","cancelled",995],
        [10,"Noah Smith","Mar 8, 2023 3:20 PM","completed","paid",170],
        [51,"Mateo Taylor","Mar 7, 2023 1:40 PM","completed","paid",770],
        [30,"Ines Kumar","Mar 4, 2023 5:20 PM","completed","paid",920],
        [14,"Felix Moreau","Feb 25, 2023 10:20 AM","completed","paid",990],
        [58,"Rosa Davis","Feb 18, 2023 3:50 PM","completed","paid",630],
        [18,"Ravi Evans","Feb 12, 2023 10:20 AM","cancelled","cancelled",1430],
        [11,"Nour Kumar","Feb 3, 2023 6:40 PM","completed","paid",555],
        [45,"Ines Diaz","Jan 22, 2023 1:15 PM","completed","paid",1190],
        [34,"Ana Tanaka","Jan 19, 2023 6:20 PM","completed","paid",970],
        [49,"Zoe Smith","Jan 10, 2023 8:50 PM","completed","paid",1135],
        [35,"Nour Shah","Jan 10, 2023 5:15 PM","completed","paid",1075],
        [48,"Kai Yilmaz","Jan 2, 2023 9:10 PM","completed","paid",255]
      ].map(function (o) { return { id: o[0], who: o[1], when: o[2], status: o[3], pay: o[4], total: o[5], mine: false }; }),
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

  /* ---------- staff login (role + passcode) ---------- */
  var STAFF_ACCOUNTS = {
    admin: { code: 'BinarySisters',      name: 'Alicia Mendoza',   title: 'Administrator' },
    staff: { code: 'BinarySistersStaff', name: 'Ramon Villanueva', title: 'Staff' }
  };
  function staffRole() { try { var r = sessionStorage.getItem('mesa_staff'); return STAFF_ACCOUNTS[r] ? r : ''; } catch (e) { return ''; } }
  var me = STAFF_ACCOUNTS[staffRole()];
  if (admin && !me) { location.replace('staff-login.html'); return; }
  function nav(href, text) { return '<a href="' + href + '"' + (page === href ? ' aria-current="page"' : '') + '>' + text + '</a>'; }
  function chrome() {
    var head;
    if (admin) {
      head = '<aside class="side"><a class="brand" href="admin.html">Mesa</a><nav aria-label="Staff">' +
        nav('admin.html', 'Today') + nav('admin-orders.html', 'Orders') + '<a href="menu.html">View customer site</a></nav>' +
        '<div class="me">' + me.name + '<br><span>' + me.title + '</span><form id="logout"><button class="link">Log out</button></form></div></aside>';
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
  if (lo) lo.addEventListener('submit', function (e) { e.preventDefault(); S.user = null; S.cart = {}; save(); try { sessionStorage.removeItem('mesa_staff'); } catch (x) {} flashNext('You have been logged out.'); location.href = 'index.html'; });

  /* ---------- pages ---------- */
  var pages = {};

  pages['index.html'] = function () {
    var d = new Date(Date.now() + 864e5), iso = d.toISOString().slice(0, 10);
    var f = $('#find'); f.date.value = iso; f.date.min = new Date().toISOString().slice(0, 10);
    f.time.innerHTML = SLOTS.map(function (s) { return '<option value="' + s + '"' + (s === '18:00' ? ' selected' : '') + '>' + t12(s) + '</option>'; }).join('');
    f.addEventListener('submit', function (e) { e.preventDefault(); location.href = 'reserve.html?date=' + f.date.value + '&time=' + f.time.value + '&guests=' + f.guests.value; });
    $('#featured').innerHTML = MENU.filter(function (m) { return [11, 12, 33, 1].indexOf(m.id) > -1; }).map(function (m) {
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

  pages['staff-login.html'] = function () {
    if (me) { location.replace('admin.html'); return; }
    $('#staffform').addEventListener('submit', function (e) {
      e.preventDefault();
      var f = e.target, role = f.role.value;
      if (f.code.value !== STAFF_ACCOUNTS[role].code) { toast('Incorrect passcode for ' + STAFF_ACCOUNTS[role].title.toLowerCase() + ' access.', 'error'); f.code.value = ''; f.code.focus(); return; }
      try { sessionStorage.setItem('mesa_staff', role); } catch (x) {}
      flashNext('Signed in as ' + STAFF_ACCOUNTS[role].name + ' (' + STAFF_ACCOUNTS[role].title.toLowerCase() + ').');
      location.href = 'admin.html';
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
      if (t.seats < guests || t.status === 'out_of_service') return false;
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
    var hi = $('#app .muted'); if (hi) hi.textContent = 'Signed in as ' + me.name + ' (' + me.title.toLowerCase() + ').';
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
