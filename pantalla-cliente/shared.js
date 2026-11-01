// Estado compartido entre el panel del colaborador y la pantalla del cliente.
// Se sincroniza con BroadcastChannel + localStorage (misma PC, sin internet).
const PC = (() => {
  const KEY = 'pc_state_v5';
  const ch = 'BroadcastChannel' in window ? new BroadcastChannel('pc_channel') : null;
  const DEFAULT = {
    items: [],            // {code,name,price,qty}
    status: 'idle',       // idle | venta | gracias
    catalog: [
      {
        "code": "2512",
        "name": "Combo 1",
        "price": 23.5,
        "cat": "Combos Salada",
        "desc": "1 Pop corn salada mediana + 1 gaseosa mediana + 1 cañonazo"
      },
      {
        "code": "3088",
        "name": "Combo 1 + Hot Dog",
        "price": 32.4,
        "cat": "Combos Salada",
        "desc": "1 Pop corn salada mediana + 1 gaseosa mediana + 1 cañonazo + 1 hot dog"
      },
      {
        "code": "2517",
        "name": "Combo 2",
        "price": 28.5,
        "cat": "Combos Salada",
        "desc": "2 Pop corn saladas chicas + 2 gaseosas chicas"
      },
      {
        "code": "2518",
        "name": "Combo 2 + Hot Dog",
        "price": 37.4,
        "cat": "Combos Salada",
        "desc": "2 Pop corn saladas chicas + 2 gaseosas chicas + 1 hot dog"
      },
      {
        "code": "2484",
        "name": "Combo 3",
        "price": 33.5,
        "cat": "Combos Salada",
        "desc": "1 Pop corn salada gigante + 2 gaseosas medianas"
      },
      {
        "code": "2485",
        "name": "Combo 3 + Hot Dog",
        "price": 42.4,
        "cat": "Combos Salada",
        "desc": "1 Pop corn salada gigante + 2 gaseosas medianas + 1 hot dog"
      },
      {
        "code": "2488",
        "name": "Combo 4",
        "price": 37.5,
        "cat": "Combos Salada",
        "desc": "1 Pop corn salada gigante + 2 gaseosas grandes"
      },
      {
        "code": "2489",
        "name": "Combo 4 + Hot Dog",
        "price": 46.4,
        "cat": "Combos Salada",
        "desc": "1 Pop corn salada gigante + 2 gaseosas grandes + 1 hot dog"
      },
      {
        "code": "2611",
        "name": "Combo Dulce 1",
        "price": 26.0,
        "cat": "Combos Dulce",
        "desc": "1 Pop corn dulce mediana + 1 gaseosa mediana + 1 cañonazo"
      },
      {
        "code": "2612",
        "name": "Combo Dulce 2",
        "price": 31.5,
        "cat": "Combos Dulce",
        "desc": "2 Pop corn dulces chicas + 2 gaseosas chicas"
      },
      {
        "code": "2613",
        "name": "Mixto 3",
        "price": 36.5,
        "cat": "Combos Dulce",
        "desc": "1 Pop corn mixta gigante + 2 gaseosas medianas"
      },
      {
        "code": "2614",
        "name": "Mixto 4",
        "price": 40.0,
        "cat": "Combos Dulce",
        "desc": "1 Pop corn mixta gigante + 2 gaseosas grandes"
      },
      {
        "code": "3135",
        "name": "Power Salad",
        "price": 35.5,
        "cat": "Combos Bar",
        "desc": "1 Pop corn salada grande + 1 pizza + 2 gaseosas chicas"
      },
      {
        "code": "3133",
        "name": "Power Dulce",
        "price": 35.5,
        "cat": "Combos Bar",
        "desc": "1 Pop corn dulce grande + 1 pizza + 2 gaseosas chicas"
      },
      {
        "code": "3615",
        "name": "VIP Individual",
        "price": 26.5,
        "cat": "Combos Vip",
        "desc": "1 Tinto de verano + 1 pizza personal"
      },
      {
        "code": "3616",
        "name": "VIP Dúo",
        "price": 39.9,
        "cat": "Combos Vip",
        "desc": "2 Tintos de verano + 1 pizza + 1 pop corn salada grande"
      },
      {
        "code": "3617",
        "name": "VIP Trío",
        "price": 54.9,
        "cat": "Combos Vip",
        "desc": "3 Tintos de verano + 1 pizza + 2 pop corn saladas grandes"
      },
      {
        "code": "0031",
        "name": "Pop Corn Salada Chico",
        "price": 14.0,
        "cat": "Salada"
      },
      {
        "code": "0032",
        "name": "Pop Corn Salada Mediano",
        "price": 15.0,
        "cat": "Salada"
      },
      {
        "code": "0033",
        "name": "Pop Corn Salada Grande",
        "price": 17.0,
        "cat": "Salada"
      },
      {
        "code": "0047",
        "name": "Pop Corn Salada Gigante",
        "price": 25.0,
        "cat": "Salada"
      },
      {
        "code": "2606",
        "name": "Pop Corn Dulce Chico",
        "price": 17.5,
        "cat": "Dulce"
      },
      {
        "code": "2607",
        "name": "Pop Corn Dulce Mediana",
        "price": 18.5,
        "cat": "Dulce"
      },
      {
        "code": "2608",
        "name": "Pop Corn Dulce Grande",
        "price": 20.5,
        "cat": "Dulce"
      },
      {
        "code": "2609",
        "name": "Pop Corn Dulce Gigante",
        "price": 30.0,
        "cat": "Dulce"
      },
      {
        "code": "2085",
        "name": "Gaseosa Vaso Chico",
        "price": 8.0,
        "cat": "Bebidas"
      },
      {
        "code": "2086",
        "name": "Gaseosa Vaso Mediano",
        "price": 10.0,
        "cat": "Bebidas"
      },
      {
        "code": "2087",
        "name": "Gaseosa Vaso Grande",
        "price": 11.5,
        "cat": "Bebidas"
      },
      {
        "code": "0026",
        "name": "Agua",
        "price": 6.5,
        "cat": "Bebidas"
      },
      {
        "code": "3090",
        "name": "Chicha Botella",
        "price": 4.5,
        "cat": "Bebidas"
      },
      {
        "code": "3830",
        "name": "Pepero",
        "price": 8.0,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "0009",
        "name": "Wafer",
        "price": 5.0,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "1911",
        "name": "Gomita Ambrosito",
        "price": 3.5,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "0016",
        "name": "Lenteja Cajita",
        "price": 5.0,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "3831",
        "name": "Choco Pie",
        "price": 3.5,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "2527",
        "name": "Cañonazo",
        "price": 3.5,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "2899",
        "name": "Nacho",
        "price": 13.5,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "0013",
        "name": "Sublime Clásico",
        "price": 5.0,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "0004",
        "name": "Travesuras",
        "price": 5.0,
        "cat": "Golosinas Y Otros"
      },
      {
        "code": "2823",
        "name": "Pizza Personal",
        "price": 17.5,
        "cat": "Golosinas Y Otros"
      }
    ],
    slides: [
      {
        "title": "",
        "sub": "",
        "image": "publicidad/avengers-doomsday.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/duna-parte-3.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/ekeko.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/el-pintor.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/godzilla.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/stray-kids.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/street-fighter.jpg"
      },
      {
        "title": "",
        "sub": "",
        "image": "publicidad/trabaja-con-nosotros.jpg"
      }
    ],
    slideSeconds: 8,
    currency: 'S/'
  };
  let state = load();
  const subs = [];
  let lastRev = null;

  function load() {
    try { return Object.assign({}, DEFAULT, JSON.parse(localStorage.getItem(KEY) || '{}')); }
    catch (e) { return structuredClone(DEFAULT); }
  }
  function save() {
    try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {}
    if (ch) ch.postMessage('update');
    notify();
  }
  function notify() { subs.forEach(f => f(state)); }
  function refresh() { state = load(); notify(); }
  if (ch) ch.onmessage = refresh;
  window.addEventListener('storage', e => { if (e.key === KEY) refresh(); });

  const total = () => state.items.reduce((s, i) => s + i.price * i.qty, 0);
  const money = n => state.currency + ' ' + n.toFixed(2);

  return {
    get state() { return state; },
    subscribe(f) { subs.push(f); f(state); },
    total, money,
    update(fn) { fn(state); save(); },
    add(prod, qty = 1) {
      this.update(s => {
        const it = s.items.find(i => i.code === prod.code && i.price === prod.price);
        if (it) it.qty += qty; else s.items.push({ ...prod, qty });
        s.status = 'venta';
      });
    },
    addByCode(code) {
      const p = state.catalog.find(c => c.code === String(code).trim());
      if (!p) return false;
      this.add(p); return true;
    },
    setQty(idx, d) {
      this.update(s => {
        s.items[idx].qty += d;
        if (s.items[idx].qty <= 0) s.items.splice(idx, 1);
        s.status = s.items.length ? 'venta' : 'idle';
      });
    },
    remove(idx) { this.update(s => { s.items.splice(idx, 1); s.status = s.items.length ? 'venta' : 'idle'; }); },
    finish() { this.update(s => { s.status = 'gracias'; }); },
    clear() { this.update(s => { s.items = []; s.status = 'idle'; }); },
    // Puente con AutoHotkey: el .ahk escribe estado.js y la pantalla del cliente lo lee cada ~0.7 s
    applyBridge(b) {
      if (!b || b.rev === lastRev) return;
      lastRev = b.rev;
      if (b.catalog && b.catalog.length) state.catalog = b.catalog.map(c => ({ ...c, price: +c.price }));
      state.items = (b.items || []).map(it => {
        const p = state.catalog.find(c => c.code === it.code) || { name: it.code, price: 0 };
        return { code: it.code, name: p.name, price: p.price, cat: p.cat, desc: p.desc, qty: +it.qty };
      });
      state.status = b.status || 'idle';
      notify();
    },
    watchBridge(ms = 700) {
      const poll = () => {
        const s = document.createElement('script');
        s.src = 'estado.js?t=' + Date.now();
        s.onload = () => { s.remove(); if (window.PC_BRIDGE) this.applyBridge(window.PC_BRIDGE); };
        s.onerror = () => s.remove();
        document.head.appendChild(s);
      };
      poll(); setInterval(poll, ms);
    },
    reset() { localStorage.removeItem(KEY); refresh(); }
  };
})();
