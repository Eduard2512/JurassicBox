# Pantalla del cliente (segundo monitor) · Movie Time

Dos paneles web (diseñados para 1920x1080 en la pantalla del cliente):
- `operador.html`: panel del colaborador (agrega productos, finaliza la venta).
- `cliente.html`: pantalla del cliente (lista, fotos, total, publicidad). Doble clic = pantalla completa.

Ambas ventanas deben abrirse en el mismo navegador (Chrome/Edge). Funciona sin internet y sin TumiSoft.

## Enlace con TumiSoft (opcional)
1. Instalar/tener AutoHotkey v1 y abrir `MovieTime-Enlace.ahk` (doble clic). Queda en la bandeja, junto al reloj.
2. Al iniciar abre solo el panel del colaborador y la pantalla del cliente (se puede desactivar en el `.ahk`).
   Si la pantalla del cliente sale en el monitor equivocado, cambiar `PantallaClienteX` al inicio del `.ahk`.
3. Cada producto que el colaborador agrega en el panel web se escribe también en el buscador de TumiSoft + Enter,
   igual que el panel anterior de AutoHotkey. Casilla **Enviar también a TumiSoft** en el panel para activarlo o no.
4. **F1** limpia el buscador de TumiSoft (como antes).
5. Quitar productos (− / ✕) solo cambia la pantalla del cliente: hay que quitarlo también en TumiSoft.
6. Cómo se comunican: el panel web escribe el código en el título de su ventana (`MTCMD|...`) y el `.ahk` lo lee.
   Por eso el panel debe estar abierto (no minimizado) y no debe llevar "TumiSoft" en el título.

## Personalizar
- Productos, precios y contenido de combos: *Configuración* de `operador.html` (formato `código;nombre;precio;categoría;contenido`;
  `catalogo-movietime.txt` tiene la lista lista para pegar).
- Fotos: `productos/<codigo>.webp` (sin foto se muestra el logo).
- Publicidad: imágenes 1920x1080 en `publicidad/`, agregadas en *Configuración*.
