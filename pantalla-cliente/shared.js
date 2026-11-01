// Estado compartido entre el panel del colaborador y la pantalla del cliente.
// Se sincroniza con BroadcastChannel + localStorage (misma PC, sin internet).
const PC = (() => {
  const KEY = 'pc_state_v1';
  const ch = 'BroadcastChannel' in window ? new BroadcastChannel('pc_channel') : null;
  const DEFAULT = {
    items: [],            // {code,name,price,qty}
    status: 'idle',       // idle | venta | gracias
    catalog: [
      { code: '1001', name: 'Canchita grande', price: 15 },
      { code: '1002', name: 'Canchita mediana', price: 12 },
      { code: '1003', name: 'Gaseosa 22oz', price: 8 },
      { code: '1004', name: 'Hot dog', price: 9 },
      { code: '1005', name: 'Combo 1 (canchita + gaseosa)', price: 20 },
      { code: '1006', name: 'Chocolate', price: 5 }
    ],
    slides: [
      { title: 'Combo Movie Time', sub: 'Canchita grande + 2 gaseosas a precio especial', image: '' },
      { title: 'Cartelera de hoy', sub: 'Consulta las funciones en boletería', image: '' }
    ],
    idleSeconds: 20,      // segundos sin actividad para pasar a publicidad
    slideSeconds: 7,
    currency: 'S/'
  };
  let state = load();
  const subs = [];

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
    reset() { localStorage.removeItem(KEY); refresh(); }
  };
})();
