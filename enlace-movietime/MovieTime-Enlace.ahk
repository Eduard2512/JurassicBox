#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
CoordMode, Mouse, Window

; ============================================================
;  ENLACE MOVIE TIME  ->  TumiSoft
;  Los paneles son web (operador.html y cliente.html, carpeta pantalla-cliente).
;  Este script SOLO hace lo de siempre: escribir el codigo en TumiSoft + Enter.
;  Se entera porque el panel web publica el codigo en el titulo de su
;  ventana (MTCMD|numero:codigo|). Vive en la bandeja (junto al reloj).
;  Si algo falla: clic derecho en el icono de la bandeja -> "Ver registro".
; ============================================================

; ----- CONFIGURACION -----
RutaWeb              := ""        ; carpeta con operador.html y cliente.html. Vacio = la busca sola (o te la pregunta una vez)
TitulosTumi          := "TumiSoft|Nuevo comprobante"           ; texto que aparece en el titulo de la ventana de TumiSoft (separar con |)
ProcesosTumi         := "tumi|grupostar"                       ; texto que aparece en el nombre del .exe de TumiSoft (separar con |)
PantallaClienteX     := 1920     ; posicion X del segundo monitor (1920 = a la derecha de un monitor 1920x1080)
Navegador            := "chrome.exe"
AbrirAlIniciar       := true     ; abre el panel y la pantalla del cliente al iniciar este script
PanelSiempreAlFrente := true     ; mantiene el panel del colaborador visible sobre TumiSoft
PanelNoActivar       := true     ; el panel NO le quita el foco a TumiSoft al hacer clic (como el panel antiguo de AutoHotkey)
SiempreClicBuscador  := false    ; true = hace clic en el buscador (si esta calibrado) aunque TumiSoft ya este activa
PausaEntreProductos  := 350      ; milisegundos entre un producto y otro cuando se envia una lista completa
PanelAncho           := 1000     ; tamano de la ventana del panel del colaborador
PanelAlto            := 720

UltimoSeq    := 0
Inicializado := false
PanelVisto   := false
PanelAplicado := 0

; ----- Registro y coordenadas guardadas -----
FileGetSize, tamLog, %A_ScriptDir%\enlace.log
if (tamLog > 200000)
    FileDelete, %A_ScriptDir%\enlace.log
IniRead, BuscadorX, %A_ScriptDir%\enlace.ini, buscador, x
IniRead, BuscadorY, %A_ScriptDir%\enlace.ini, buscador, y

; ----- Localizar la carpeta pantalla-cliente -----
if (RutaWeb = "")
    IniRead, RutaWeb, %A_ScriptDir%\enlace.ini, web, ruta
if (RutaWeb = "ERROR" || !FileExist(RutaWeb . "\operador.html"))
    RutaWeb := BuscarCarpetaWeb()
intentos := 0
while (RutaWeb = "" && intentos < 3)
{
    intentos++
    MsgBox, 64, Movie Time, No encuentro la carpeta pantalla-cliente (la que contiene operador.html).`n`nEn la siguiente ventana selecciona esa carpeta.
    FileSelectFolder, elegida, , 0, Selecciona la carpeta pantalla-cliente
    if (elegida = "")
        break
    elegida := RTrim(elegida, "\")
    if FileExist(elegida . "\operador.html")
        RutaWeb := elegida
    else if FileExist(elegida . "\pantalla-cliente\operador.html")
        RutaWeb := elegida . "\pantalla-cliente"
    else
        MsgBox, 48, Movie Time, Esa carpeta no contiene operador.html.
}
if (RutaWeb != "")
    IniWrite, %RutaWeb%, %A_ScriptDir%\enlace.ini, web, ruta
Log("=== Enlace iniciado ===  web: " . RutaWeb)

; ----- Menu de la bandeja -----
Menu, Tray, Tip, Movie Time - Enlace TumiSoft
Menu, Tray, Add
Menu, Tray, Add, Abrir panel del colaborador, AbrirPanel
Menu, Tray, Add, Abrir pantalla del cliente, AbrirCliente
Menu, Tray, Add, Panel siempre al frente, AlternarFrente
Menu, Tray, Add, Panel sin robar el foco a TumiSoft, AlternarFoco
Menu, Tray, Add
Menu, Tray, Add, Calibrar buscador de TumiSoft (5 segundos), CalibrarBuscador
Menu, Tray, Add, Probar 1: escribir 0031 en la ventana activa, ProbarEnvio
Menu, Tray, Add, Probar 2: envio automatico completo, ProbarAuto
Menu, Tray, Add, Mostrar ventanas detectadas, VerVentanas
Menu, Tray, Add, Ver registro (enlace.log), VerRegistro
if (PanelSiempreAlFrente)
    Menu, Tray, Check, Panel siempre al frente
if (PanelNoActivar)
    Menu, Tray, Check, Panel sin robar el foco a TumiSoft

if (RutaWeb = "")
{
    Log("ERROR: no se encontro la carpeta pantalla-cliente")
    AbrirAlIniciar := false
}

SetTimer, Revisar, 80
if (AbrirAlIniciar)
{
    Gosub, AbrirPanel
    Gosub, AbrirCliente
}
return

; ----- LEE LOS COMANDOS QUE PUBLICA EL PANEL WEB -----
Revisar:
panel := WinExist("Panel colaborador ahk_class Chrome_WidgetWin_1")
if (panel && panel != PanelAplicado)
{
    if (PanelNoActivar)
        WinSet, ExStyle, +0x08000000, ahk_id %panel%
    if (PanelSiempreAlFrente)
        WinSet, AlwaysOnTop, On, ahk_id %panel%
    PanelAplicado := panel
    Log("Panel configurado (sin robar foco: " . PanelNoActivar . ", al frente: " . PanelSiempreAlFrente . ")")
}
hwnd := WinExist("MTCMD|")
if (!hwnd)
{
    Inicializado := true
    return
}
WinGetTitle, titulo, ahk_id %hwnd%
pos := InStr(titulo, "MTCMD|")
if (!pos)
    return
if (!PanelVisto)
{
    PanelVisto := true
    Log("Panel web detectado, titulo: " . titulo)
}
resto := SubStr(titulo, pos + 6)
fin := InStr(resto, "|")
if (fin)
    resto := SubStr(resto, 1, fin - 1)

if (!Inicializado)
{
    ; comando que ya estaba en el titulo al abrir este script: no se reenvia
    Loop, Parse, resto, `;
    {
        partes := StrSplit(A_LoopField, ":")
        s := partes[1] + 0
        if (s > UltimoSeq)
            UltimoSeq := s
    }
    Inicializado := true
    return
}

nuevos := []
Loop, Parse, resto, `;
{
    partes := StrSplit(A_LoopField, ":")
    s := partes[1] + 0
    codigo := partes[2]
    if (s > UltimoSeq && codigo != "")
    {
        UltimoSeq := s
        nuevos.Push(codigo)
    }
}
if (nuevos.Length() > 0)
{
    Log("Comandos recibidos del panel: " . nuevos.Length())
    EnviarLote(nuevos)
}
return

; ----- ABRIR VENTANAS -----
AbrirPanel:
url := UrlArchivo(RutaWeb . "\operador.html")
AbrirApp(url, "--window-size=" . PanelAncho . "," . PanelAlto . " --window-position=20,20")
return

AbrirCliente:
url := UrlArchivo(RutaWeb . "\cliente.html")
AbrirApp(url, "--window-position=" . PantallaClienteX . ",0 --start-fullscreen")
return

AlternarFrente:
PanelSiempreAlFrente := !PanelSiempreAlFrente
Menu, Tray, ToggleCheck, Panel siempre al frente
if (!PanelSiempreAlFrente)
    WinSet, AlwaysOnTop, Off, Panel colaborador ahk_class Chrome_WidgetWin_1
PanelAplicado := 0
return

AlternarFoco:
PanelNoActivar := !PanelNoActivar
Menu, Tray, ToggleCheck, Panel sin robar el foco a TumiSoft
if (!PanelNoActivar)
    WinSet, ExStyle, -0x08000000, Panel colaborador ahk_class Chrome_WidgetWin_1
PanelAplicado := 0
Log("Panel sin robar foco: " . PanelNoActivar)
return

; ----- DIAGNOSTICO -----
; PRUEBA 1: tu haces clic en el buscador de TumiSoft y a los 5 segundos se escribe 0031 en la ventana que este activa.
; Sirve para saber si escribir funciona, sin depender del foco ni de la calibracion.
ProbarEnvio:
Aviso("PRUEBA 1: haz clic en el buscador de TumiSoft. En 5 segundos se escribe 0031 ahi.", 5500)
Sleep, 5000
ToolTip
WinGetTitle, tact, A
WinGet, eact, ProcessName, A
Log("Prueba 1 - ventana activa: " . eact . " | " . tact)
SetKeyDelay, 40
SendEvent, 0031{Enter}
Log("Prueba 1 - enviado 0031 a la ventana activa")
return

; PRUEBA 2: el script hace todo solo (activa TumiSoft, hace clic si esta calibrado y escribe).
ProbarAuto:
Aviso("PRUEBA 2: en 3 segundos el script escribe 0031 en TumiSoft.", 3500)
Sleep, 3000
Log("Prueba 2 - envio automatico (codigo 0031)")
EnviarATumi("0031")
return

; Calibrar: pon el mouse sobre el cuadro "Buscar productos" de TumiSoft (o presiona F8 con el mouse ahi).
CalibrarBuscador:
Loop, 5
{
    n := 6 - A_Index
    msg := "Pon el mouse sobre el cuadro Buscar productos de TumiSoft. Guardando en " . n
    ToolTip, %msg%
    Sleep, 1000
}
ToolTip
Gosub, GuardarCalibracion
return

VerRegistro:
Run, notepad.exe "%A_ScriptDir%\enlace.log"
return

VerVentanas:
texto := ""
WinGet, lista, List
Loop, %lista%
{
    id := lista%A_Index%
    WinGetTitle, t, ahk_id %id%
    if (t = "")
        continue
    WinGet, exe, ProcessName, ahk_id %id%
    texto .= exe . "   |   " . t . "`n"
}
encontrada := BuscarTumiSoft()
if (encontrada)
{
    WinGetTitle, tt, ahk_id %encontrada%
    cabecera := "Ventana de TumiSoft detectada: " . tt . "`n`n"
}
else
    cabecera := "NO se detecto la ventana de TumiSoft.`nCopia de la lista el texto del titulo o del .exe de TumiSoft y ponlo en TitulosTumi / ProcesosTumi al inicio del script.`n`n"
MsgBox, 0, Ventanas abiertas, %cabecera%%texto%
return

QuitarAviso:
ToolTip
return

; ----- F1: limpia el buscador de TumiSoft (como antes) -----
F1::
id := BuscarTumiSoft()
if (id)
{
    WinActivate, ahk_id %id%
    WinWaitActive, ahk_id %id%,, 2
    Sleep, 100
    Send, ^a{Backspace}
}
return

; ----- F8: calibrar. Pon el mouse sobre el cuadro "Buscar productos" de TumiSoft y presiona F8.
;       Desde entonces se hace clic ahi antes de escribir cada codigo. -----
F8::
Gosub, GuardarCalibracion
return

GuardarCalibracion:
CoordMode, Mouse, Screen
MouseGetPos, sx, sy, wid
WinGetPos, wx, wy,,, ahk_id %wid%
mx := sx - wx
my := sy - wy
WinGetTitle, tact, ahk_id %wid%
CoordMode, Mouse, Window
BuscadorX := mx
BuscadorY := my
IniWrite, %mx%, %A_ScriptDir%\enlace.ini, buscador, x
IniWrite, %my%, %A_ScriptDir%\enlace.ini, buscador, y
Log("Calibrado buscador en x=" . mx . " y=" . my . " dentro de la ventana: " . tact)
Aviso("Buscador guardado (" . mx . "," . my . ") en: " . tact)
return

; ----- F9: borrar la calibracion -----
F9::
BuscadorX := "ERROR"
BuscadorY := "ERROR"
IniDelete, %A_ScriptDir%\enlace.ini, buscador
Log("Calibracion borrada")
Aviso("Calibracion borrada")
return

; ============================================================
;  FUNCIONES
; ============================================================

; Un solo codigo
EnviarATumi(codigo)
{
    EnviarLote([codigo])
}

; Escribe uno o varios codigos en TumiSoft, uno por uno (codigo + Enter).
; Activa TumiSoft y hace el clic en el buscador UNA sola vez, al inicio del lote.
EnviarLote(codigos)
{
    global BuscadorX, BuscadorY, SiempreClicBuscador, PausaEntreProductos
    total := codigos.Length()
    id := BuscarTumiSoft()
    if (!id)
    {
        Log("ERROR: no encuentro la ventana de TumiSoft (" . total . " codigo(s))")
        Aviso("No encuentro la ventana de TumiSoft.`nClic derecho en el icono de la bandeja > Mostrar ventanas detectadas")
        return
    }
    WinGetTitle, t, ahk_id %id%
    yaActiva := WinActive("ahk_id " . id)
    calibrado := (BuscadorX != "ERROR" && BuscadorX != "")
    clic := false
    if (!yaActiva)
    {
        WinActivate, ahk_id %id%
        WinWaitActive, ahk_id %id%,, 2
        if (ErrorLevel)
            Log("AVISO: TumiSoft no quedo activa en 2 s (titulo: " . t . ")")
        Sleep, 200
        clic := calibrado
    }
    else if (calibrado && SiempreClicBuscador)
        clic := true
    if (clic)
    {
        SetMouseDelay, 0
        CoordMode, Mouse, Screen
        MouseGetPos, ox, oy
        CoordMode, Mouse, Window
        MouseClick, Left, %BuscadorX%, %BuscadorY%, 1, 0
        Sleep, 200
        CoordMode, Mouse, Screen
        MouseMove, %ox%, %oy%, 0
        CoordMode, Mouse, Window
        Send, ^a
        Sleep, 50
    }
    SetKeyDelay, 40
    enviados := 0
    for i, codigo in codigos
    {
        ; si el usuario cambio de ventana a mitad del envio, se corta para no escribir en otro programa
        if (!WinActive("ahk_id " . id))
        {
            WinActivate, ahk_id %id%
            WinWaitActive, ahk_id %id%,, 2
            if (ErrorLevel)
            {
                Log("ERROR: se perdio TumiSoft a mitad del envio (" . enviados . " de " . total . ")")
                Aviso("Envio detenido: TumiSoft dejo de estar activa (" . enviados . " de " . total . " enviados)")
                return
            }
            Sleep, 150
        }
        if (total > 1)
        {
            msg := "Enviando a TumiSoft: " . i . " de " . total . "  (no muevas el mouse ni el teclado)"
            ToolTip, %msg%
        }
        SendEvent, %codigo%{Enter}
        enviados++
        Log("Enviado a TumiSoft: " . codigo . "  (" . i . "/" . total . ", ventana: " . t . ", ya activa: " . (yaActiva ? "si" : "no") . ", clic en buscador: " . (clic ? "si" : "no") . ")")
        if (i < total)
            Sleep, %PausaEntreProductos%
    }
    if (total > 1)
        Aviso("Listo: " . total . " producto(s) enviados a TumiSoft", 2500)
}

; Busca la ventana de TumiSoft por nombre del .exe o por el titulo
BuscarTumiSoft()
{
    global TitulosTumi, ProcesosTumi
    WinGet, lista, List
    Loop, %lista%
    {
        id := lista%A_Index%
        WinGetTitle, t, ahk_id %id%
        if (t = "")
            continue
        if (InStr(t, "MTCMD") || InStr(t, "Panel colaborador") || InStr(t, "Pantalla cliente"))
            continue
        WinGet, exe, ProcessName, ahk_id %id%
        if exe in explorer.exe,AutoHotkey.exe,notepad.exe
            continue
        Loop, Parse, ProcesosTumi, |
        {
            if (A_LoopField != "" && InStr(exe, A_LoopField))
                return id
        }
        Loop, Parse, TitulosTumi, |
        {
            if (A_LoopField != "" && InStr(t, A_LoopField))
                return id
        }
    }
    return 0
}

; Busca pantalla-cliente en lugares comunes (junto al script, Descargas, Escritorio, Documentos)
BuscarCarpetaWeb()
{
    EnvGet, perfil, USERPROFILE
    bases := [A_ScriptDir, A_ScriptDir . "\..", A_ScriptDir . "\..\..", perfil . "\Downloads", perfil . "\Desktop", perfil . "\Documents"]
    subs := ["\pantalla-cliente", "\pantalla-cliente\pantalla-cliente", "\MovieTime\pantalla-cliente"]
    for i, b in bases
    {
        for j, sb in subs
        {
            ruta := RutaCompleta(b . sb)
            if FileExist(ruta . "\operador.html")
                return ruta
        }
    }
    return ""
}

; Quita los ".." de una ruta
RutaCompleta(ruta)
{
    VarSetCapacity(buf, 1040, 0)
    DllCall("GetFullPathName", "Str", ruta, "UInt", 520, "Str", buf, "Ptr", 0)
    return buf
}

UrlArchivo(ruta)
{
    u := StrReplace(RutaCompleta(ruta), "\", "/")
    u := StrReplace(u, " ", "%20")
    return "file:///" . u
}

AbrirApp(url, extra)
{
    global Navegador
    try
    {
        Run, %Navegador% --app="%url%" %extra%
        Log("Abierto: " . url)
        return true
    }
    catch
    {
        try
        {
            Run, msedge.exe --app="%url%" %extra%
            Log("Abierto con Edge: " . url)
            return true
        }
        catch
        {
            Log("ERROR: no pude abrir Chrome ni Edge")
            MsgBox, 48, Movie Time, No pude abrir Chrome ni Edge. Abre manualmente operador.html y cliente.html.
            return false
        }
    }
}

Aviso(texto, ms := 5000)
{
    ToolTip, %texto%
    SetTimer, QuitarAviso, % -ms
}

Log(texto)
{
    FormatTime, hora,, yyyy-MM-dd HH:mm:ss
    FileAppend, %hora%  %texto%`n, %A_ScriptDir%\enlace.log, UTF-8
}
