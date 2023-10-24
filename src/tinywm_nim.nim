import std/bitops
import x11/xlib
import x11/x

var
  display: PDisplay
  root: x.Window
  attr: XWindowAttributes
  start: XButtonEvent
  ev: XEvent

proc maxNum(x, y: cuint): cuint = return if x >= y: x else: y

proc main(): int =
  display = XOpenDisplay(nil)
  if display == nil:
    quit "Failed to open display"
  
  root = DefaultRootWindow(display)
  discard display.XGrabKey(cint(display.XKeysymToKeycode("F1".XStringToKeysym)), Mod1Mask, root,
    1, GrabModeAsync, GrabModeAsync)
  discard display.XGrabButton(1, Mod1Mask, root, 1, ButtonPressMask, GrabModeAsync,
    GrabModeAsync, None, None)
  discard display.XGrabButton(3, Mod1Mask, root, 1, ButtonPressMask, GrabModeAsync,
    GrabModeAsync, None, None)
  
  while true:
    discard display.XNextEvent(ev.addr)
    if ev.theType == KeyPress and ev.xkey.subwindow != None:
      discard display.XRaiseWindow(ev.xkey.subwindow)
    elif ev.theType == ButtonPress and ev.xbutton.subwindow != None:
      discard display.XGrabPointer(ev.xbutton.subwindow, 1,
        PointerMotionMask.bitor(ButtonReleaseMask), GrabModeAsync, GrabModeAsync,
        None, None, CurrentTime)
      discard display.XGetWindowAttributes(ev.xbutton.subwindow, attr.addr)
      start = ev.xbutton
    elif ev.theType == MotionNotify:
      var xdiff, ydiff: cint
      while display.XCheckTypedEvent(MotionNotify, ev.addr) == 1: discard nil
      xdiff = ev.xbutton.x_root - start.x_root
      ydiff = ev.xbutton.y_root - start.y_root
      discard display.XMoveResizeWindow(ev.xmotion.window,
        attr.x + (if start.button == 1: xdiff else: 0),
        attr.y + (if start.button == 1: ydiff else: 0),
        maxNum(cuint(1), cuint(attr.width + (if start.button == 3: xdiff else: 0))),
        maxNum(cuint(1), cuint(attr.height + (if start.button == 3: ydiff else: 0)))
      )
    elif ev.theType == ButtonRelease:
      discard display.XUngrabPointer(CurrentTime)

discard main()
