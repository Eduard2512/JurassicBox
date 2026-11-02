// Estado compartido entre el panel del colaborador y la pantalla del cliente.
// Se sincroniza con BroadcastChannel + localStorage (misma PC, sin internet).
const PC = (() => {
  const KEY = 'pc_state_v6';
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
        "desc": "1 Pop corn dulce mediana + 1 gaseosa mediana + 1 cañonazo",
        "img": "2512"
      },
      {
        "code": "2612",
        "name": "Combo Dulce 2",
        "price": 31.5,
        "cat": "Combos Dulce",
        "desc": "2 Pop corn dulces chicas + 2 gaseosas chicas",
        "img": "2517"
      },
      {
        "code": "2613",
        "name": "Mixto 3",
        "price": 36.5,
        "cat": "Combos Dulce",
        "desc": "1 Pop corn mixta gigante + 2 gaseosas medianas",
        "img": "2484"
      },
      {
        "code": "2614",
        "name": "Mixto 4",
        "price": 40.0,
        "cat": "Combos Dulce",
        "desc": "1 Pop corn mixta gigante + 2 gaseosas grandes",
        "img": "2488"
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
        "cat": "Dulce",
        "img": "0031"
      },
      {
        "code": "2607",
        "name": "Pop Corn Dulce Mediana",
        "price": 18.5,
        "cat": "Dulce",
        "img": "0032"
      },
      {
        "code": "2608",
        "name": "Pop Corn Dulce Grande",
        "price": 20.5,
        "cat": "Dulce",
        "img": "0033"
      },
      {
        "code": "2609",
        "name": "Pop Corn Dulce Gigante",
        "price": 30.0,
        "cat": "Dulce",
        "img": "0047"
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
        "name": "Super Pizza Personal",
        "price": 17.5,
        "cat": "Sandwich Y Embutidos"
      },
      {
        "code": "1677",
        "name": "Hot Dog",
        "price": 11.5,
        "cat": "Sandwich Y Embutidos"
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
    currency: 'S/',
    custom: { catalog: false, slides: false }   // true = lo edito el usuario en Configuracion (se conserva al actualizar el programa)
  };
  let lastRaw = null, thanksTimer = 0;
  let state = load();
  const subs = [];

  function load() {
    let st = {};
    try { lastRaw = localStorage.getItem(KEY); st = JSON.parse(lastRaw || '{}') || {}; } catch (e) { st = {}; }
    const s = Object.assign({}, structuredClone(DEFAULT), st);
    s.custom = Object.assign({ catalog: false, slides: false }, st.custom);
    // sin edicion del usuario se usa siempre el catalogo y la publicidad del programa
    if (!s.custom.catalog) s.catalog = structuredClone(DEFAULT.catalog);
    if (!s.custom.slides) { s.slides = structuredClone(DEFAULT.slides); s.slideSeconds = DEFAULT.slideSeconds; }
    return s;
  }
  function save() {
    const out = Object.assign({}, state);
    if (!state.custom.catalog) delete out.catalog;
    if (!state.custom.slides) { delete out.slides; delete out.slideSeconds; }
    try { lastRaw = JSON.stringify(out); localStorage.setItem(KEY, lastRaw); } catch (e) {}
    if (ch) ch.postMessage('update');
    notify();
  }
  function notify() { subs.forEach(f => f(state)); }
  function refresh() {
    let raw = null;
    try { raw = localStorage.getItem(KEY); } catch (e) {}
    if (raw === lastRaw) return;          // BroadcastChannel y 'storage' avisan los dos: se procesa una sola vez
    state = load(); notify();
  }
  if (ch) ch.onmessage = refresh;
  window.addEventListener('storage', e => { if (e.key === KEY) refresh(); });

  const cents = n => Math.round(n * 100);
  const lineTotal = i => cents(i.price) * i.qty / 100;
  const total = () => state.items.reduce((s, i) => s + cents(i.price) * i.qty, 0) / 100;
  const money = n => state.currency + ' ' + n.toFixed(2);

  return {
    get state() { return state; },
    subscribe(f) { subs.push(f); f(state); },
    total, lineTotal, money,
    update(fn) { fn(state); save(); },
    add(prod, qty = 1) {
      clearTimeout(thanksTimer);
      this.update(s => {
        if (s.status === 'gracias') s.items = [];      // venta nueva mientras se mostraba "Gracias"
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
        const it = s.items[idx];
        if (!it) return;
        it.qty += d;
        if (it.qty <= 0) s.items.splice(idx, 1);
        s.status = s.items.length ? 'venta' : 'idle';
      });
    },
    remove(idx) { this.update(s => { s.items.splice(idx, 1); s.status = s.items.length ? 'venta' : 'idle'; }); },
    // Muestra "Gracias" y limpia la venta despues de `ms`, salvo que se empiece otra venta mientras tanto
    finish(ms = 6000) {
      if (!state.items.length) return;
      clearTimeout(thanksTimer);
      this.update(s => { s.status = 'gracias'; });
      thanksTimer = setTimeout(() => { if (state.status === 'gracias') this.clear(); }, ms);
    },
    clear() { clearTimeout(thanksTimer); this.update(s => { s.items = []; s.status = 'idle'; }); },
    // Vuelve al catalogo y publicidad originales del programa
    resetConfig() { this.update(s => { s.custom = { catalog: false, slides: false }; s.catalog = structuredClone(DEFAULT.catalog); s.slides = structuredClone(DEFAULT.slides); s.slideSeconds = DEFAULT.slideSeconds; }); },
    // Enlace con TumiSoft: el panel publica el codigo en el titulo de su ventana
    // (MTCMD|<seq>:<codigo>;...|) y MovieTime-Enlace.ahk lo lee y lo escribe en TumiSoft.
    link: (() => {
      const K = 'pc_link_mode', base = document.title;   // modo: live | end | off
      let q = [], last = 0, timer = 0;
      const clean = c => String(c || '').replace(/[^A-Za-z0-9]/g, '');
      const getMode = () => {
        try { const m = localStorage.getItem(K); if (m) return m; return localStorage.getItem('pc_link_on') === '0' ? 'off' : 'live'; }
        catch (e) { return 'live'; }
      };
      const publish = codes => {
        const now = Date.now();
        q = q.filter(c => now - c.t < 10000);
        codes.forEach(code => { const seq = Math.max(last + 1, Date.now() * 1000); last = seq; q.push({ seq, code, t: now }); });
        document.title = base + ' MTCMD|' + q.map(c => c.seq + ':' + c.code).join(';') + '|';
        clearTimeout(timer);
        timer = setTimeout(() => { document.title = base; q = []; }, Math.min(20000, 1500 + 450 * q.length));
      };
      return {
        get mode() { return getMode(); },
        set mode(v) { try { localStorage.setItem(K, v); } catch (e) {} },
        // modo "mientras agrego": envia el codigo de inmediato
        send(code) { code = clean(code); if (code && getMode() === 'live') { publish([code]); return true; } return false; },
        // modo "al final": envia una lista de codigos (uno por uno, en orden)
        sendMany(codes) { codes = codes.map(clean).filter(Boolean); if (codes.length && getMode() !== 'off') { publish(codes); return true; } return false; }
      };
    })(),
    reset() { try { localStorage.removeItem(KEY); } catch (e) {} state = load(); notify(); }
  };
})();
