" Author:  Eric Van Dewoestine
" Version: $Revision$
"
" Description: {{{
"   see http://eclim.sourceforge.net/vim/python/regex.html
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

" Script Variables {{{
if exists('g:EclimPythonSignificantPackages')
  let s:significant_packages = g:EclimPythonSignificantPackages
else
  let s:significant_packages = []
endif
" }}}

" SortImports() {{{
function! eclim#python#import#SortImports ()
  let line = line('.')
  let col = col('.')

  let import_data = eclim#python#import#GetImports()
  let imports = import_data.imports
  call sort(imports, 'eclim#python#import#CompareImports')

  let saved = @"

  " remove unsorted imports from the file
  silent exec import_data.start . ',' . import_data.end . 'delete'

  let pre_packages = copy(s:significant_packages)
  let post_packages = copy(s:significant_packages)

  " re-insert sorted imports in the file
  let @" = ''
  let lastimport = ''
  for import in imports
    if @" != ''
      let @" .= "\n"
    endif

    " blank line to seperate significant imports
    let index = 0
    for package in pre_packages
      if import =~ '^\(from\|import\)\s*' . package . '\>'
        if @" != ''
          let @" .= "\n"
        endif
        call remove(pre_packages, index)
        break
      endif
      let index += 1
    endfor

    " post significant package seperation
    let index = 0
    for package in post_packages
      if lastimport =~ '^\(from\|import\)\s*' . package . '\>' &&
          \ import !~ '^\(from\|import\)\s*' . package . '\>'
        if @" !~ "\n\n$"
          let @" .= "\n"
        endif
        call remove(post_packages, index)
        break
      endif
      let index += 1
    endfor

    if lastimport =~ '^import' && import =~ '^from'
      let @" .= "\n"
    endif

    let @" .= import
    let lastimport = import
  endfor
  call cursor(import_data.start - 1, 1)
  silent put

  let @" = saved
  call cursor(line, col)
endfunction " }}}

" CompareImports() {{{
function! eclim#python#import#CompareImports (i1, i2)
  if (a:i1 =~ '^from' && a:i2 =~ '^from') ||
    \ (a:i1 =~ '^import' && a:i2 =~ '^import')
    return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
  endif

  if a:i1 =~ '^import'
    return -1
  endif

  if a:i1 =~ '^from'
    return 1
  endif

  return 0
endfunction " }}}

" CleanImports() {{{
function! eclim#python#import#CleanImports ()
  let line = line('.')
  let col = col('.')

  let import_data = eclim#python#import#GetImports()
  let names = []
  for import in import_data.imports
    let importing = import
    let importing = substitute(importing,
      \ '.*\<import\>\s\+\(.\{-}\<as\>\s\+\)\?\(.\{-}\)\s*$', '\2', '')
    let importing = substitute(importing, '\(\s\+\|\\\|\n\)', '', 'g')
    let names += split(importing, ',')
  endfor

  let remove = []
  call cursor(import_data.end, len(getline(import_data.end)))
  for name in names
    if !search('\<' . name . '\>', 'cnW')
      call add(remove, name)
    endif
  endfor

  let saved = @"
  for name in remove
    call cursor(1, 1)
    call search('\<' . name . '\>', 'W', import_data.end)
    let import = getline('.')
    if import =~ '\<import\>\s\+' . name . '\>\s*$' ||
     \ import =~ '\<import\>\s\+.*as\s\+' . name . '\>\s*$'
      exec line('.') . ',' . line('.') . 'delete'
      " if deleting of import results in 2 blank lines, delete one of them
      if getline('.') =~ '^\s*$' && getline(line('.') - 1) =~ '^\s*$'
        exec line('.') . ',' . line('.') . 'delete'
      endif
    else
      if import =~ ',\s*\<' . name . '\>'
        let newimport = substitute(import, ',\s*\<' . name . '\>', '', '')
      else
        let newimport = substitute(import, '\<' . name . '\>\s*,\s\?', '', '')
      endif
      call setline(line('.'), newimport)
    endif
  endfor
  let @" = saved

  call cursor(line, col)
endfunction " }}}

" GetImports() {{{
" Returns a dictionary containing:
"   - start: the line where the imports start (0 if none).
"   - end: the line where the imports end (0 if none).
"   - imports: list containing the import lines.
function! eclim#python#import#GetImports ()
  let line = line('.')
  let col = col('.')

  call cursor(1, 1)

  let imports = []
  let start = 0
  let end = 0
  while search('^\(import\|from\)\>\s\+', 'cW') && end != line('$')
    let import = getline('.')
    while import =~ '\\\s*$'
      call cursor(line('.') + 1, 1)
      let import = import . "\n" . getline('.')
    endwhile
    if len(imports) == 0
      let start = line('.')
    endif
    let end = line('.')
    call add(imports, import)
    call cursor(line('.') + 1, 1)
  endwhile

  call cursor(line, col)

  return {'start': start, 'end': end, 'imports': imports}
endfunction " }}}

" vim:ft=vim:fdm=marker
