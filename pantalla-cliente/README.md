# Pantalla del cliente (segundo monitor) · Movie Time

Diseñada para 1920x1080. Hay dos formas de usarla:

## A) Enlazada a TumiSoft (la que se usa en caja)
1. Tener AutoHotkey v1 instalado (el mismo que ya usan).
2. Doble clic en `MovieTime-Enlace.ahk`. Es el panel de siempre: cada botón escribe el código en TumiSoft + Enter,
   y además avisa a la pantalla del cliente (escribe `estado.js` en esta carpeta).
3. En el panel, botón **Abrir pantalla del cliente** (o abrir `cliente.html` en Chrome y moverla al segundo monitor, doble clic = pantalla completa).
   Si sale en el monitor equivocado, cambiar `PantallaClienteX` al inicio del `.ahk`.
4. Teclas: **F1** limpia el buscador de TumiSoft · **F2** finalizar (muestra "Gracias") · **F3** limpiar pantalla del cliente.
   Clic derecho en un producto muestra qué contiene.
5. Si se quita un producto en TumiSoft, usar **Quitar último** o **Limpiar pantalla** para que la pantalla del cliente coincida.
6. Desmarcar "Enviar también a TumiSoft" para probar sin tocar el sistema de ventas.

Productos y precios: editar `catalogo-movietime.txt` (`código;nombre;precio;categoría;contenido`) y reiniciar el `.ahk`.

## B) Solo visual (sin TumiSoft)
Abrir `operador.html` y `cliente.html` en el mismo navegador. El colaborador agrega productos desde el panel web.

## Personalizar
- Fotos: `productos/<codigo>.webp` (sin foto se muestra el logo).
- Publicidad: imágenes 1920x1080 en `publicidad/`, agregadas en *Configuración* de `operador.html` (modo B).
