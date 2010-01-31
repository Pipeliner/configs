" Author:  Eric Van Dewoestine
" Version: $Revision$
"
" Description: {{{
"   see http://eclim.sourceforge.net/vim/common/vcs.html
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

if !exists('g:eclim_vcs_cvs_loaded')
  let g:eclim_vcs_cvs_loaded = 1
else
  finish
endif

" GetAnnotations (revision) {{{
function! eclim#vcs#impl#cvs#GetAnnotations (revision)
  if exists('b:vcs_props')
    if filereadable(b:vcs_props.path)
      let file = fnamemodify(b:vcs_props.path, ':t')
    else
      let file = b:vcs_props.svn_root_url . b:vcs_props.path
    endif
  else
    let file = expand('%')
  endif

  let cmd = 'annotate'
  if a:revision != ''
    let cmd .= ' -r ' . a:revision
  endif

  let result = eclim#vcs#impl#cvs#Cvs(cmd . ' "' . file . '"')
  let annotations = split(result, '\n')
  call filter(annotations, 'v:val =~ "^[0-9]"')
  call map(annotations,
    \ "substitute(v:val, '^\\s*\\([0-9.]\\+\\)\\s*(\\(.\\{-}\\)\\s\\+\\(.\\{-}\\)).*', '\\1 (\\3) \\2', '')")

  if v:shell_error
    call eclim#util#EchoError(result)
    return
  endif

  return annotations
endfunction " }}}

" GetRelativePath(dir, file) {{{
function eclim#vcs#impl#cvs#GetRelativePath (dir, file)
  let lines = readfile(escape(a:dir . '/CVS/Repository', ' '), '', 1)
  return '/' . lines[0] . '/' . a:file
endfunction " }}}

" GetPreviousRevision() {{{
function eclim#vcs#impl#cvs#GetPreviousRevision ()
  let log = eclim#vcs#impl#cvs#Cvs('log ' . expand('%:t'))
  let lines = split(log, '\n')
  call filter(lines, 'v:val =~ "^revision [0-9.]\\+\\s*$"')
  if len(lines) >= 2
    return substitute(lines[1], '^revision \([0-9.]\+\)\s*.*', '\1', '')
  endif

  return
endfunction " }}}

" GetRevision(file) {{{
function eclim#vcs#impl#cvs#GetRevision (file)
  let status = eclim#vcs#impl#cvs#Cvs('status ' . fnamemodify(a:file, ':t'))
  let pattern = '.*Working revision:\s*\([0-9.]\+\)\s*.*'
  if status =~ pattern
    return substitute(status, pattern, '\1', '')
  endif

  return
endfunction " }}}

" GetRevisions() {{{
function eclim#vcs#impl#cvs#GetRevisions ()
  let log = eclim#vcs#impl#cvs#Cvs('log ' . expand('%:t'))
  let lines = split(log, '\n')
  call filter(lines, 'v:val =~ "^revision [0-9.]\\+\\s*$"')
  call map(lines, 'substitute(v:val, "^revision \\([0-9.]\\+\\)\\s*$", "\\1", "")')
  return lines
endfunction " }}}

" GetRoot() {{{
function eclim#vcs#impl#cvs#GetRoot ()
  let dir = substitute(getcwd(), '\', '/', 'g')
  let lines = readfile(dir . '/CVS/Repository', '', 1)
  let remove = len(split(lines[0], '/'))
  let root = join(split(dir, '/')[:0 - remove], '/')
  if has('unix')
    return '/' . root
  endif
  return root
endfunction " }}}

" Info() {{{
" Retrieves and echos info on the current file.
function eclim#vcs#impl#cvs#Info ()
  let result = eclim#vcs#impl#cvs#Cvs('status "' . expand('%:t') . '"')
  if type(result) == 0
    return
  endif
  let info = split(result, "\n")[1:]
  call map(info, "substitute(v:val, '^\\s\\+', '', '')")
  call map(info, "substitute(v:val, '\\t', ' ', 'g')")
  let info[0] = substitute(info[0], '.\{-}\(Status:.*\)', '\1', '')
  call eclim#util#Echo(join(info, "\n"))
endfunction " }}}

" ListDir([path]) {{{
function eclim#vcs#impl#cvs#ListDir (...)
  let lines = [s:Breadcrumb(a:000[0]), '']
  " alternate solution if Entries doesn't have dirs in it
  "let dirs = split(globpath('.', '*/CVS'), '\n')
  "let dirs = dirs + split( globpath('.', '.*/CVS'), '\n')
  "call map(dirs, 'split(v:val, "/")[1] . "/"')
  "call filter(dirs, 'v:val !~ "\\./"')
  let contents = readfile('CVS/Entries')
  let dirs = filter(copy(contents), 'v:val =~ "^D/"')
  let files = filter(copy(contents), 'v:val =~ "^/"')
  call map(dirs, 'substitute(v:val, "^D/\\(.\\{-}/\\).*", "|\\1|", "")')
  call map(files, 'substitute(v:val, "^/\\(.\\{-}\\)/.*", "|\\1|", "")')
  call sort(dirs)
  call sort(files)
  call extend(lines, dirs)
  call extend(lines, files)

  let root_dir = exists('b:vcs_props') ?
    \ b:vcs_props.root_dir : eclim#vcs#impl#cvs#GetRoot()
  return {'list': lines, 'props': {'root_dir': root_dir}}
endfunction " }}}

" Log([file]) {{{
function eclim#vcs#impl#cvs#Log (...)
  if len(a:000) > 0
    let path = fnamemodify(a:000[0], ':t')
  else
    let path = expand('%:t')
  endif

  let result = eclim#vcs#impl#cvs#Cvs('log "' . path . '"')
  if type(result) == 0
    return
  endif
  let log = s:ParseCvsLog(split(result, '\n'))

  let index = 0
  let lines = [s:Breadcrumb(path), '']
  for entry in log
    let index += 1
    call add(lines, '------------------------------------------')
    call add(lines, 'Revision: ' . entry.revision . ' |view| |annotate|')
    call add(lines, 'Modified: ' . entry.date . ' by ' . entry.author)
    let working_copy = ''
    if (isdirectory(path) || filereadable(path)) &&
     \ (!exists('b:filename') || b:filename =~ path . '$')
      let working_copy = ' |working copy|'
    endif
    if index < len(log)
      call add(lines, 'Diff: |previous ' . log[index].revision . '|' . working_copy)
    elseif working_copy != ''
      call add(lines, 'Diff: |working copy|')
    endif
    call add(lines, '')
    let lines += entry.comment
    if lines[-1] !~ '^\s*$' && index != len(log)
      call add(lines, '')
    endif
  endfor
  let root_dir = exists('b:vcs_props') ?
    \ b:vcs_props.root_dir : eclim#vcs#impl#cvs#GetRoot()
  return {'log': lines, 'props': {'root_dir': root_dir}}
endfunction " }}}

" ViewFileRevision(path, revision) {{{
function! eclim#vcs#impl#cvs#ViewFileRevision (path, revision)
  let path = fnamemodify(a:path, ':t')
  let result = eclim#vcs#impl#cvs#Cvs('annotate -r ' . a:revision . ' "' . path . '"')
  let content = split(result, '\n')
  let content = map(content[2:], 'substitute(v:val, "^.\\{-}):\\s", "", "")')
  return content
endfunction " }}}

" Cvs(args) {{{
" Executes 'cvs' with the supplied args.
function eclim#vcs#impl#cvs#Cvs (args)
  return eclim#vcs#util#Vcs('cvs', a:args)
endfunction " }}}

" s:Breadcrumb(path) {{{
function! s:Breadcrumb (path)
  if a:path == ''
    return '/'
  endif

  let file = exists('b:vcs_props') && isdirectory(b:vcs_props.root_dir . '/' . a:path) ?
    \ '' : a:path
  let path = split(eclim#vcs#impl#cvs#GetRelativePath('.', file), '/')
  let dirs = map(path[:-2], '"|" . v:val . "|"')
  return join(dirs, ' / ') . ' / ' . path[-1]
endfunction " }}}

" s:ParseCvsLog(lines) {{{
function! s:ParseCvsLog (lines)
  let log = []
  let section = 'head'
  let index = 0
  for line in a:lines
    let index += 1
    if line =~ '^=\+$'
      break
    elseif line =~ '^-\+$'
      let section = 'info'
      let entry = {'comment': []}
      call add(log, entry)
      continue
    elseif section == 'head'
      continue
    elseif section == 'info'
      let entry.revision = substitute(line, 'revision ', '', '')
      let section = 'date_author'
    elseif section == 'date_author'
      let entry.date = substitute(line, 'date: \(.\{-}\);.*', '\1', '')
      let entry.author = substitute(line, '.*author: \(.\{-}\);.*', '\1', '')
      let section = 'comment'
    elseif section == 'comment'
      let line = substitute(line, '\(#\d\+\)', '|\1|', 'g')
      call add(entry.comment, line)
    endif
  endfor
  return log
endfunction " }}}

" vim:ft=vim:fdm=marker
