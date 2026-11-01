#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
FileEncoding, UTF-8

; ============================================================
;  PANEL MOVIE TIME  ->  TumiSoft + Pantalla del cliente
;  Igual que antes: cada boton escribe el codigo en TumiSoft + Enter.
;  Nuevo: ademas avisa a la pantalla del cliente (cliente.html)
;  escribiendo el archivo estado.js en esta misma carpeta.
;  Los productos salen de catalogo-movietime.txt (codigo;nombre;precio;categoria;contenido)
; ============================================================

; ----- CONFIGURACION -----
PantallaClienteX := 1920      ; posicion X del segundo monitor (1920 = a la derecha de un monitor 1920x1080)
SegundosGracias  := 6         ; cuanto se muestra "Gracias" al finalizar
Navegador        := "chrome.exe"

; ----- CARGAR CATALOGO -----
Prod    := {}     ; Prod["C2512"] := {code, name, price, cat, desc}
Orden   := []     ; codigos en orden
Cats    := []     ; categorias en orden
PorCat  := {}     ; PorCat[categoria] := [codigos]
Items   := []     ; venta actual: [{code, qty}]
Estado  := "idle" ; idle | venta | gracias

if !FileExist("catalogo-movietime.txt")
{
    MsgBox, 16, Movie Time, No se encontro catalogo-movietime.txt en:`n%A_ScriptDir%
    ExitApp
}
Loop, Read, catalogo-movietime.txt
{
    linea := Trim(A_LoopReadLine)
    if (linea = "")
        continue
    p := StrSplit(linea, ";")
    code  := Trim(p[1])
    name  := Trim(p[2])
    price := StrReplace(Trim(p[3]), ",", ".")
    cat   := Trim(p[4])
    desc  := Trim(p[5])
    if (code = "" || name = "")
        continue
    if (price = "")
        price := "0"
    if (cat = "")
        cat := "Otros"
    Prod["C" . code] := {code: code, name: name, price: price, cat: cat, desc: desc}
    Orden.Push(code)
    if !PorCat.HasKey(cat)
    {
        PorCat[cat] := []
        Cats.Push(cat)
    }
    PorCat[cat].Push(code)
}

; ----- VENTANA -----
Gui, +AlwaysOnTop +E0x08000000
Gui, Color, FFFFFF
Gui, Font, s10 w700, Segoe UI
Gui, Add, Text, c0044CC Center w580, PANEL MOVIE TIME - CHORRILLOS
Gui, Font, s9 w400, Segoe UI

tabNames := ""
for i, c in Cats
    tabNames .= (i = 1 ? "" : "|") . c
Gui, Add, Tab3, vMiTab x10 y30 w580 h520, %tabNames%

for i, c in Cats
{
    Gui, Tab, %i%
    lista := PorCat[c]
    n := lista.Length()
    filas := Ceil(n / 2)
    for k, code in lista
    {
        col := (k - 1) // filas
        fila := Mod(k - 1, filas)
        x := 22 + col * 280
        y := 70 + fila * 42
        pr := Prod["C" . code]
        etiqueta := pr.name . "  (S/ " . pr.price . ")"
        Gui, Add, Button, x%x% y%y% w262 h36 vC%code% gMandar, %etiqueta%
    }
}
Gui, Tab

Gui, Add, Checkbox, vEnviarTumi Checked x15 y560, Enviar tambien a TumiSoft (desmarcar = solo pantalla del cliente)
Gui, Add, Button, x10 y588 w185 h36 gQuitarUltimo, Quitar ultimo
Gui, Add, Button, x203 y588 w185 h36 gFinalizar, Finalizar (Gracias)  [F2]
Gui, Add, Button, x396 y588 w194 h36 gLimpiar, Limpiar pantalla  [F3]
Gui, Add, Button, x10 y632 w580 h32 gAbrirCliente, Abrir pantalla del cliente (segundo monitor)
Gui, Add, Text, vResumen x15 y672 w570, Sin productos
Gui, Show, w600, Panel Movie Time - Enlace TumiSoft
GuardarEstado()
return

; ----- AYUDA: clic derecho en un producto muestra su contenido -----
GuiContextMenu:
if (A_GuiControl = "")
    return
clave := A_GuiControl
if !Prod.HasKey(clave)
    return
info := Prod[clave].desc
if (info = "")
    info := "Sin detalle."
ToolTip, %info%
SetTimer, QuitarToolTip, -4500
return

QuitarToolTip:
ToolTip
return

; ----- MOTOR DE ENVIO (igual que antes + pantalla del cliente) -----
Mandar:
codigo := SubStr(A_GuiControl, 2)
GuiControlGet, EnviarTumi
if (EnviarTumi)
{
    IfWinExist, TumiSoft
    {
        WinActivate, TumiSoft
        Sleep, 50
        SetKeyDelay, 40
        SendEvent, %codigo%{Enter}
    }
}
AgregarItem(codigo)
return

QuitarUltimo:
SetTimer, FinGracias, Off
n := Items.Length()
if (n = 0)
    return
Items[n].qty := Items[n].qty - 1
if (Items[n].qty <= 0)
    Items.Pop()
Estado := (Items.Length() > 0) ? "venta" : "idle"
GuardarEstado()
return

Finalizar:
F2::
if (Items.Length() = 0)
    return
Estado := "gracias"
GuardarEstado()
ms := SegundosGracias * 1000
SetTimer, FinGracias, % -ms
return

FinGracias:
Items := []
Estado := "idle"
GuardarEstado()
return

Limpiar:
F3::
SetTimer, FinGracias, Off
Items := []
Estado := "idle"
GuardarEstado()
return

AbrirCliente:
url := "file:///" . StrReplace(A_ScriptDir, "\", "/") . "/cliente.html"
Run, %Navegador% --new-window --app="%url%" --window-position=%PantallaClienteX%`,0 --start-fullscreen
return

; F1: limpia el buscador de TumiSoft (como antes)
F1::
IfWinExist, TumiSoft
{
    WinActivate, TumiSoft
    Sleep, 50
    Send, ^a{Backspace}
}
return

GuiClose:
Items := []
Estado := "idle"
GuardarEstado()
ExitApp

; ============================================================
;  FUNCIONES
; ============================================================
AgregarItem(codigo)
{
    global Items, Estado
    encontrado := false
    for i, it in Items
    {
        if (it.code = codigo)
        {
            it.qty := it.qty + 1
            encontrado := true
            break
        }
    }
    if (!encontrado)
        Items.Push({code: codigo, qty: 1})
    Estado := "venta"
    GuardarEstado()
}

JsonEsc(s)
{
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, """", "\""")
    return s
}

GuardarEstado()
{
    global Items, Estado, Orden, Prod
    itemsJs := ""
    total := 0
    unidades := 0
    for i, it in Items
    {
        itemsJs .= (itemsJs = "" ? "" : ",") . "{""code"":""" . JsonEsc(it.code) . """,""qty"":" . it.qty . "}"
        total += Prod["C" . it.code].price * it.qty
        unidades += it.qty
    }
    catJs := ""
    for i, code in Orden
    {
        p := Prod["C" . code]
        catJs .= (catJs = "" ? "" : ",") . "{""code"":""" . JsonEsc(p.code) . """,""name"":""" . JsonEsc(p.name) . """,""price"":" . p.price . ",""cat"":""" . JsonEsc(p.cat) . """,""desc"":""" . JsonEsc(p.desc) . """}"
    }
    rev := A_Now . A_MSec
    out := "window.PC_BRIDGE={""rev"":""" . rev . """,""status"":""" . Estado . """,""items"":[" . itemsJs . "],""catalog"":[" . catJs . "]};"
    tmp := A_ScriptDir . "\estado.tmp"
    f := FileOpen(tmp, "w", "UTF-8-RAW")
    if (f)
    {
        f.Write(out)
        f.Close()
        FileMove, %tmp%, %A_ScriptDir%\estado.js, 1
    }
    if (unidades = 0)
        GuiControl,, Resumen, Sin productos
    else
        GuiControl,, Resumen, % unidades . " producto(s)  -  Total S/ " . Round(total, 2)
}
