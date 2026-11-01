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
PanelAncho           := 1000     ; tamano de la ventana del panel del colaborador
PanelAlto            := 720

UltimoSeq    := 0
Inicializado := false
PanelVisto   := false

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
Menu, Tray, Add
Menu, Tray, Add, Probar envio a TumiSoft (codigo 0031), ProbarEnvio
Menu, Tray, Add, Mostrar ventanas detectadas, VerVentanas
Menu, Tray, Add, Ver registro (enlace.log), VerRegistro
if (PanelSiempreAlFrente)
    Menu, Tray, Check, Panel siempre al frente

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

Loop, Parse, resto, `;
{
    partes := StrSplit(A_LoopField, ":")
    s := partes[1] + 0
    codigo := partes[2]
    if (s > UltimoSeq && codigo != "")
    {
        UltimoSeq := s
        Log("Comando recibido del panel: " . codigo)
        EnviarATumi(codigo)
    }
}
if (PanelSiempreAlFrente)
    WinSet, AlwaysOnTop, On, ahk_id %hwnd%
return

; ----- ABRIR VENTANAS -----
AbrirPanel:
url := UrlArchivo(RutaWeb . "\operador.html")
AbrirApp(url, "--window-size=" . PanelAncho . "," . PanelAlto . " --window-position=20,20")
if (PanelSiempreAlFrente)
{
    WinWait, Panel colaborador,, 10
    WinSet, AlwaysOnTop, On, Panel colaborador
}
return

AbrirCliente:
url := UrlArchivo(RutaWeb . "\cliente.html")
AbrirApp(url, "--window-position=" . PantallaClienteX . ",0 --start-fullscreen")
return

AlternarFrente:
PanelSiempreAlFrente := !PanelSiempreAlFrente
Menu, Tray, ToggleCheck, Panel siempre al frente
if (!PanelSiempreAlFrente)
    WinSet, AlwaysOnTop, Off, Panel colaborador
return

; ----- DIAGNOSTICO -----
ProbarEnvio:
Log("Prueba manual desde la bandeja (codigo 0031)")
EnviarATumi("0031")
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

; Escribe el codigo en TumiSoft + Enter (igual que el panel anterior, con mas esperas y avisos)
EnviarATumi(codigo)
{
    global BuscadorX, BuscadorY
    id := BuscarTumiSoft()
    if (!id)
    {
        Log("ERROR: no encuentro la ventana de TumiSoft (codigo " . codigo . ")")
        Aviso("No encuentro la ventana de TumiSoft.`nClic derecho en el icono de la bandeja > Mostrar ventanas detectadas")
        return
    }
    WinGetTitle, t, ahk_id %id%
    WinActivate, ahk_id %id%
    WinWaitActive, ahk_id %id%,, 2
    if (ErrorLevel)
        Log("AVISO: TumiSoft no quedo activa en 2 s (titulo: " . t . ")")
    Sleep, 150
    if (BuscadorX != "ERROR" && BuscadorX != "")
    {
        CoordMode, Mouse, Screen
        MouseGetPos, ox, oy
        CoordMode, Mouse, Window
        Click, %BuscadorX%, %BuscadorY%
        Sleep, 100
        CoordMode, Mouse, Screen
        MouseMove, %ox%, %oy%, 0
        CoordMode, Mouse, Window
    }
    SetKeyDelay, 40
    SendEvent, %codigo%{Enter}
    Log("Enviado a TumiSoft: " . codigo . "  (ventana: " . t . ")")
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
