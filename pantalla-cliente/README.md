# Pantalla del cliente (segundo monitor) · Movie Time

Dos paneles web (diseñados para 1920x1080 en la pantalla del cliente):
- `operador.html`: panel del colaborador (agrega productos, finaliza la venta). Arriba a la derecha muestra una **miniatura de lo que ve el cliente** (botón Ocultar/Mostrar).
- `cliente.html`: pantalla del cliente (lista, fotos, total, publicidad). Doble clic = pantalla completa.

Ambas ventanas deben abrirse en el mismo navegador (Chrome/Edge). Funciona sin internet y sin TumiSoft.

## Enlace con TumiSoft (opcional)
Está en la carpeta `enlace-movietime/` (solo texto, sin imágenes). Ver `enlace-movietime/LEEME.txt`.
En el panel, **Enviar a TumiSoft** tiene tres modos: *Mientras agrego* (cada producto se escribe en el buscador de TumiSoft + Enter al agregarlo),
*Al final de la venta* (botón que escribe toda la lista, uno por uno) y *No enviar*. Quitar productos (− / ✕) solo cambia la pantalla del cliente:
hay que quitarlo también en TumiSoft. El panel debe estar abierto y no llevar "TumiSoft" en su título.

## Personalizar
- Productos, precios y contenido de combos: *Configuración* de `operador.html` (formato `código;nombre;precio;categoría;contenido;foto`;
  `catalogo-movietime.txt` tiene la lista lista para pegar). Lo que guardas ahí se conserva al actualizar el programa;
  **Restaurar originales** vuelve a la lista que trae el programa.
- Fotos: `productos/<codigo>.webp` (sin foto se muestra el logo). El campo `foto` permite reutilizar la imagen de otro código (p. ej. el pop corn dulce usa la del salado).
- Publicidad: imágenes 1920x1080 en `publicidad/`, agregadas en *Configuración*.
