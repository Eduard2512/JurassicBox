#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

; ============================================================
;  ENLACE MOVIE TIME  ->  TumiSoft
;  Los paneles son web (operador.html y cliente.html).
;  Este script solo hace lo de siempre: escribir el codigo en
;  TumiSoft + Enter. Se entera porque el panel web publica el
;  codigo en el titulo de su ventana (MTCMD|numero:codigo|).
;  Sin ventanas propias: vive en la bandeja (junto al reloj).
; ============================================================

; ----- CONFIGURACION -----
PantallaClienteX     := 1920     ; posicion X del segundo monitor (1920 = a la derecha de un monitor 1920x1080)
Navegador            := "chrome.exe"
AbrirAlIniciar       := true     ; abre el panel y la pantalla del cliente al iniciar este script
PanelSiempreAlFrente := true     ; mantiene el panel del colaborador visible sobre TumiSoft
PanelAncho           := 1000     ; tamano de la ventana del panel del colaborador
PanelAlto            := 720

UltimoSeq    := 0
Inicializado := false

Menu, Tray, Tip, Movie Time - Enlace TumiSoft
Menu, Tray, Add
Menu, Tray, Add, Abrir panel del colaborador, AbrirPanel
Menu, Tray, Add, Abrir pantalla del cliente, AbrirCliente
Menu, Tray, Add, Panel siempre al frente, AlternarFrente
if (PanelSiempreAlFrente)
    Menu, Tray, Check, Panel siempre al frente

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
        EnviarATumi(codigo)
    }
}
if (PanelSiempreAlFrente)
    WinSet, AlwaysOnTop, On, ahk_id %hwnd%
return

; ----- ABRIR VENTANAS -----
AbrirPanel:
url := "file:///" . StrReplace(A_ScriptDir, "\", "/") . "/operador.html"
Run, %Navegador% --app="%url%" --window-size=%PanelAncho%`,%PanelAlto% --window-position=20`,20
if (PanelSiempreAlFrente)
{
    WinWait, Panel colaborador,, 10
    WinSet, AlwaysOnTop, On, Panel colaborador
}
return

AbrirCliente:
url := "file:///" . StrReplace(A_ScriptDir, "\", "/") . "/cliente.html"
Run, %Navegador% --app="%url%" --window-position=%PantallaClienteX%`,0 --start-fullscreen
return

AlternarFrente:
PanelSiempreAlFrente := !PanelSiempreAlFrente
Menu, Tray, ToggleCheck, Panel siempre al frente
if (!PanelSiempreAlFrente)
    WinSet, AlwaysOnTop, Off, Panel colaborador
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

; ----- MOTOR DE ENVIO (igual que el panel anterior) -----
EnviarATumi(codigo)
{
    IfWinExist, TumiSoft
    {
        WinActivate, TumiSoft
        Sleep, 50
        SetKeyDelay, 40
        SendEvent, %codigo%{Enter}
    }
}
