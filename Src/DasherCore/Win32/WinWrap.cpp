// WinMrap.cpp
//
/////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2002 Iain Murray, Inference Group, Cavendish, Cambridge.
//
/////////////////////////////////////////////////////////////////////////////

#include "WinCommon.h"

#include "WinWrap.h"

CWinWrap::~CWinWrap() {
  DestroyWindow(m_hwnd);
  WinWrapMap::remove(m_hwnd);
}

namespace WinWrapMap {
  WNDPROC GetWndProc(HWND Win);
    std::map < HWND, CWinWrap * >WinMap;
    std::map < Tstring, short >ClassRegistered;
} LRESULT CALLBACK WinWrapMap::WndProc(HWND Window, UINT message, WPARAM wParam, LPARAM lParam) {
  CWinWrap *WinWrap = WinMap[Window];

  /* A WinWrap object may be deleted before the Window has stopped processing
     messages. Also DialogBox() does not return, so we didn't get a change to add
     a dialog to the map. Therefore, we check that the object still exists first. */
  if(WinWrap != 0)
    return WinWrap->WndProc(Window, message, wParam, lParam);
  else {
    if(message == WM_INITDIALOG) {
      // Objects representing dialogs should pass a pointer to themselves by using DialogBoxParam
      if(lParam) {
        WinWrapMap::add(Window, (CWinWrap *) lParam);   // Ugly casting
        WinWrap = WinMap[Window];
        return WinWrap->WndProc(Window, message, wParam, lParam);
      }
      else
        return FALSE;
    }
    else {
      return DefWindowProc(Window, message, wParam, lParam);
    }
  }

  return 0;
}

void WinWrapMap::add(HWND Win, CWinWrap *WinObject) {
  WinMap[Win] = WinObject;
}

void WinWrapMap::remove(HWND Win) {
  WinMap.erase(Win);
  CWinWrap *foo = WinMap[Win];
  return;
}

bool WinWrapMap::Register(TCHAR *WndClassName) {
  if(ClassRegistered[Tstring(WndClassName)] == 0) {
    ClassRegistered[Tstring(WndClassName)] = 1;
    return true;
  }
  else {
    return false;
  }
}