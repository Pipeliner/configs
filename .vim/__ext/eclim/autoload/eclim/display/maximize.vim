" Author:  Eric Van Dewoestine
" Version: $Revision$
"
" Description: {{{
"   see http://eclim.sourceforge.net/vim/common/maximize.html
"
" License:
"
" Copyright (c) 2005 - 2008
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"      http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.
"
" }}}

" Global Variables {{{
  if !exists('g:MaximizeExcludes')
    let g:MaximizeExcludes =
      \ '\(ProjectTree_*\|__Tag_List__\|-MiniBufExplorer-\|command-line\)'
  endif
  if !exists('g:MaximizeMinWinHeight')
    let g:MaximizeMinWinHeight = 0
  endif
  if !exists('g:MaximizeMinWinWidth')
    let g:MaximizeMinWinWidth = 0
  endif
  if !exists('g:MaximizeQuickfixHeight')
    let g:MaximizeQuickfixHeight = 10
  endif
  if !exists('g:MaximizeSpecialtyWindowsRestore')
    let g:MaximizeSpecialtyWindowsRestore = [
        \ ['g:TagList_title', '"vertical <window>resize " . g:Tlist_WinWidth'],
        \ [
          \ 'g:EclimProjectTreeTitle',
          \ '"vertical <window>resize " . g:EclimProjectTreeWidth'
        \ ],
      \ ]
  endif
" }}}

" MaximizeWindow() {{{
function! eclim#display#maximize#MaximizeWindow ()
  " disable any minimize settings
  call eclim#display#maximize#ResetMinimized()

  " get the window that is maximized
  let maximized = eclim#display#maximize#GetMaximizedWindow()
  if maximized
    call s:DisableMaximizeAutoCommands()
    call eclim#display#maximize#RestoreWindows(maximized)
  else
    exec "set winminwidth=" . g:MaximizeMinWinWidth
    exec "set winminheight=" . g:MaximizeMinWinHeight
    call eclim#display#maximize#MaximizeUpdate()
  endif
endfunction " }}}

" MinimizeWindow() {{{
function! eclim#display#maximize#MinimizeWindow (...)
  let curwinnum = winnr()

  exec "set winminheight=" . g:MaximizeMinWinHeight
  exec "set winminwidth=" . g:MaximizeMinWinWidth
  call s:DisableMaximizeAutoCommands()

  " first turn off maximized if enabled
  let maximized = eclim#display#maximize#GetMaximizedWindow()
  if maximized
    call eclim#display#maximize#RestoreWindows(maximized)
  endif

  let args = []
  if len(a:000) == 0
    let args = [winnr()]
  else
    let args = a:000[:]
  endif

  " first loop through and mark the buffers
  for winnum in args
    call setwinvar(winnum, "minimized", 1)
  endfor

  call s:Reminimize()
endfunction " }}}

" MaximizeUpdate() {{{
function! eclim#display#maximize#MaximizeUpdate ()
  if expand('%') !~ g:MaximizeExcludes && !exists('b:eclim_temp_window') && &ft != 'qf'
    call s:DisableMaximizeAutoCommands()

    let w:maximized = 1
    winc |
    winc _

    " check to see if a quickfix / eclim temp window is open
    let winend = winnr('$')
    let winnum = 1
    while winnum <= winend
      let buffernum = winbufnr(winnum)
      let buffername = bufname(buffernum)
      if getwinvar(winnum, '&ft') == 'qf'
        let quickfixwindow = winnum
      elseif getbufvar(buffernum, 'eclim_temp_window')
        let eclimtempwindow = winnum
      endif
      let winnum = winnum + 1
    endwhile

    if exists("quickfixwindow")
      exec quickfixwindow . "resize " . g:MaximizeQuickfixHeight
      exec "vertical " . quickfixwindow . "resize"
    endif

    if exists("eclimtempwindow")
      exec eclimtempwindow . "resize 10"
      exec "vertical " . eclimtempwindow . "resize"
    endif

    call s:RestoreFixedWindows()
    call s:EnableMaximizeAutoCommands()
  endif
endfunction " }}}

" GetMaximizedWindow() {{{
function! eclim#display#maximize#GetMaximizedWindow ()
  let winend = winnr('$')
  let winnum = 1
  while winnum <= winend
    let max = getwinvar(winnum, "maximized")
    if max
      return winnum
    endif
    let winnum = winnum + 1
  endwhile

  return 0
endfunction " }}}

" ResetMinimized() {{{
function! eclim#display#maximize#ResetMinimized ()
  call s:DisableMinimizeAutoCommands()
  let winend = winnr('$')
  let winnum = 1
  while winnum <= winend
    call setwinvar(winnum, "minimized", 0)
    call setwinvar(winnum, "&winfixheight", 0)
    call setwinvar(winnum, "&winfixwidth", 0)
    let winnum = winnum + 1
  endwhile
endfunction " }}}

" DisableMaximizeAutoCommands() {{{
function! s:DisableMaximizeAutoCommands ()
  augroup maximize
    autocmd!
  augroup END
endfunction " }}}

" EnableMaximizeAutoCommands() {{{
function! s:EnableMaximizeAutoCommands ()
  call s:DisableMaximizeAutoCommands()
  call s:DisableMinimizeAutoCommands()
  augroup maximize
    autocmd!
    autocmd BufReadPost quickfix
      \ call eclim#display#maximize#AdjustFixedWindow(g:MaximizeQuickfixHeight, 1)
    autocmd BufUnload * call s:CloseFixedWindow()
    autocmd BufWinEnter,WinEnter * nested call eclim#display#maximize#MaximizeUpdate()
  augroup END
endfunction " }}}

" DisableMinimizeAutoCommands() {{{
function! s:DisableMinimizeAutoCommands ()
  augroup minimize
    autocmd!
  augroup END
endfunction " }}}

" EnableMinimizeAutoCommands() {{{
function! s:EnableMinimizeAutoCommands ()
  call s:DisableMaximizeAutoCommands()
  augroup minimize
    autocmd!
    autocmd BufReadPost quickfix
      \ call eclim#display#maximize#AdjustFixedWindow(g:MaximizeQuickfixHeight, 0)
    autocmd BufWinEnter,WinEnter * nested call s:Reminimize()
  augroup END
endfunction " }}}

" AdjustFixedWindow(height, maximize) {{{
function! eclim#display#maximize#AdjustFixedWindow (height, maximize)
  exec "resize " . a:height
  set winfixheight

  if a:maximize
    "return to previous window to restore it's maximized
    let curwindow = winnr()
    winc p
    call eclim#display#maximize#MaximizeUpdate()
    exec curwindow . "winc w"
  endif
endfunction " }}}

" CloseFixedWindow() {{{
function! s:CloseFixedWindow ()
  if expand('<afile>') == "" || exists('b:eclim_temp_window')
    let maximized = eclim#display#maximize#GetMaximizedWindow()
    if maximized
      call eclim#util#DelayedCommand('call eclim#display#maximize#MaximizeUpdate()')
    endif
  endif
endfunction " }}}

" Reminimize() {{{
" Invoked when changing windows to ensure that any minimized windows are
" returned to their minimized state.
function s:Reminimize ()
  call s:DisableMinimizeAutoCommands()
  let curwinnum = winnr()
  let winend = winnr('$')
  let winnum = 1
  let commands = []
  while winnum <= winend
    if bufname(winbufnr(winnum)) !~ g:MaximizeExcludes
      let minimized = getwinvar(winnum, "minimized")
      if minimized
        let row_wins = s:RowMinimized(winnum)
        let column_wins = s:ColumnMinimized(winnum)
        "let vertical_split = s:IsVerticalSplit(winnum)

        "echom 'buffer = ' . winbufnr(winnum)
        "echom '  row minimized    = ' . len(row_wins)
        "echom '  column minimized = ' . len(column_wins)
        "echom '  in row           = ' . s:IsInRow(winnum)
        "echom '  in column        = ' . s:IsInColumn(winnum)

        "if vertical_split && len(row_wins) && len(column_wins)
        "  exec "vertical " . winnum . "resize 0"
        "  call setwinvar(winnum, "&winfixwidth", 1)

        if len(row_wins) && len(column_wins)
          call add(commands, winnum . "resize 0")
          call setwinvar(winnum, "&winfixheight", 1)

        elseif len(column_wins)
          call add(commands, "vertical " . winnum . "resize 0")
          call setwinvar(winnum, "&winfixwidth", 1)

        elseif s:IsInRow(winnum)
          call add(commands, "vertical " . winnum . "resize 0")
          call setwinvar(winnum, "&winfixwidth", 1)

        elseif s:IsInColumn(winnum)
          call add(commands, winnum . "resize 0")
          call setwinvar(winnum, "&winfixheight", 1)

        "elseif vertical_split
        "  exec "vertical " . winnum . "resize 0"
        "  call setwinvar(winnum, "&winfixwidth", 1)

        else
          call add(commands, winnum . "resize 0")
          call add(commands, "vertical " . winnum . "resize 0")
          call setwinvar(winnum, "&winfixheight", 1)
          call setwinvar(winnum, "&winfixwidth", 1)
        endif
      endif
    endif
    let winnum = winnum + 1
  endwhile

  " ensure we end up in the window we started in
  exec curwinnum . 'winc w'

  " run all the resizing commands
  for cmd in commands
    exec cmd
  endfor

  call s:RestoreFixedWindows()

  winc =

  call s:RestoreFixedWindows()
  call s:EnableMinimizeAutoCommands()
endfunction " }}}

" RestoreWindows(maximized) {{{
function! eclim#display#maximize#RestoreWindows (maximized)
  " reset the maximized var.
  if a:maximized
    call setwinvar(a:maximized, "maximized", 0)
  endif

  winc _
  winc =

  call s:RestoreFixedWindows()

  let curwinnr = winnr()
  winc w
  while winnr() != curwinnr
    if &ft == 'qf'
      exec "resize " . g:MaximizeQuickfixHeight
    endif
    winc w
  endwhile
endfunction " }}}

" RestoreFixedWindows() {{{
function! s:RestoreFixedWindows ()
  for settings in g:MaximizeSpecialtyWindowsRestore
    if exists(settings[0]) || settings[0] =~ '^".*"$'
      exec 'let name = ' . settings[0]
      let winnr = bufwinnr('*' . name . '*')
      if winnr != -1
        exec 'exec ' . substitute(settings[1], '<window>', winnr, 'g')
      endif
    endif
  endfor
endfunction " }}}

" IsVerticalSplit(window) {{{
" Determines if the current window is vertically split.
"function! s:IsVerticalSplit (window)
"  let origwinnr = winnr()
"
"  exec a:window . 'winc w'
"  let curwinnr = winnr()
"
"  " check to the right
"  winc l
"  if winnr() != curwinnr && expand('%') !~ g:MaximizeExcludes
"    return 1
"  endif
"
"  exec a:window . 'winc w'
"
"  " check to the left
"  winc h
"  if winnr() != curwinnr && expand('%') !~ g:MaximizeExcludes
"    return 1
"  endif
"
"  exec origwinnr . 'winc w'
"  return 0
"endfunction " }}}

" IsInRow(window) {{{
" Determines if the supplied window is in a row of equally sized windows.
function! s:IsInRow (window)
  let origwinnr = winnr()
  exec a:window . 'winc w'

  " check windows to the right
  let curwinnr = winnr()
  winc l
  while winnr() != curwinnr
    let curwinnr = winnr()
    if winheight(curwinnr) == winheight(a:window)
      exec origwinnr . 'winc w'
      return 1
    endif
    winc l
  endwhile

  exec a:window . 'winc w'

  " check windows to the left
  let curwinnr = winnr()
  winc h
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winheight(curwinnr) == winheight(a:window)
      exec origwinnr . 'winc w'
      return 1
    endif
    winc h
  endwhile

  exec origwinnr . 'winc w'
  return 0
endfunction " }}}

" IsInColumn(window) {{{
" Determines is the supplied window is in a column of equally sized windows.
function! s:IsInColumn (window)
  let origwinnr = winnr()
  exec a:window . 'winc w'

  " check windows above
  let curwinnr = winnr()
  winc k
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winwidth(curwinnr) == winwidth(a:window)
      exec origwinnr . 'winc w'
      return 1
    endif
    winc k
  endwhile

  exec a:window . 'winc w'

  " check windows below
  let curwinnr = winnr()
  winc j
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winwidth(curwinnr) == winwidth(a:window)
      exec origwinnr . 'winc w'
      return 1
    endif
    winc j
  endwhile

  exec origwinnr . 'winc w'
  return 0
endfunction " }}}

" RowMinimized(window) {{{
" Determines all windows on a row are minimized.
function! s:RowMinimized (window)
  let origwinnr = winnr()
  exec a:window . 'winc w'

  let windows = []

  " check windows to the right
  let curwinnr = winnr()
  winc l
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winheight(curwinnr) == winheight(a:window) &&
        \ expand('%') !~ g:MaximizeExcludes
      if getwinvar(curwinnr, 'minimized') == ''
        exec origwinnr . 'winc w'
        return []
      else
        call add(windows, curwinnr)
      endif
    endif
    winc l
  endwhile

  exec a:window . 'winc w'

  " check windows to the left
  let curwinnr = winnr()
  winc h
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winheight(curwinnr) == winheight(a:window) &&
        \ expand('%') !~ g:MaximizeExcludes
      if getwinvar(curwinnr, 'minimized') == ''
        exec origwinnr . 'winc w'
        return []
      else
        call add(windows, curwinnr)
      endif
    endif
    winc h
  endwhile

  exec origwinnr . 'winc w'
  return windows
endfunction " }}}

" ColumnMinimized(window) {{{
" Determines all windows in column are minimized.
function! s:ColumnMinimized (window)
  let origwinnr = winnr()
  exec a:window . 'winc w'

  let windows = []

  " check windows above
  let curwinnr = winnr()
  winc k
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winwidth(curwinnr) == winwidth(a:window) &&
        \ expand('%') !~ g:MaximizeExcludes
      if getwinvar(curwinnr, 'minimized') == ''
        exec origwinnr . 'winc w'
        return []
      else
        call add(windows, curwinnr)
      endif
    endif
    winc k
  endwhile

  exec a:window . 'winc w'

  " check windows below
  let curwinnr = winnr()
  winc j
  while winnr() != curwinnr
    let buffer = bufnr('%')
    let curwinnr = winnr()
    if winwidth(curwinnr) == winwidth(a:window) &&
        \ expand('%') !~ g:MaximizeExcludes
      if getwinvar(curwinnr, 'minimized') == ''
        exec origwinnr . 'winc w'
        return []
      else
        call add(windows, curwinnr)
      endif
    endif
    winc j
  endwhile

  exec origwinnr . 'winc w'
  return windows
endfunction " }}}

" NavigateWindows(cmd) {{{
" Used navigate windows by skipping minimized windows.
function! eclim#display#maximize#NavigateWindows (wincmd)
  let start = winnr()
  let lastwindow = start

  exec a:wincmd
  while exists('w:minimized') && w:minimized && winnr() != lastwindow
    let lastwindow = winnr()
    exec a:wincmd
  endwhile

  if exists('w:minimized') && w:minimized
    exec start . 'wincmd w'
  endif
endfunction " }}}

" vim:ft=vim:fdm=marker
