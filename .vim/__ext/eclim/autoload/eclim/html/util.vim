" Author:  Eric Van Dewoestine
" Version: $Revision: 1677 $
"
" Description: {{{
"   Various html relatd functions.
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

" HtmlToText() {{{
" Converts the supplied basic html to text.
function! eclim#html#util#HtmlToText (html)
  let text = a:html
  let text = substitute(text, '<br/\?>\c', '\n', 'g')
  let text = substitute(text, '</\?b>\c', '', 'g')
  let text = substitute(text, '</\?ul>\c', '', 'g')
  let text = substitute(text, '<li>\c', '- ', 'g')
  let text = substitute(text, '</li>\c', '', 'g')
  let text = substitute(text, '</\?p/\?>\c', '', 'g')
  let text = substitute(text, '</\?code>\c', '', 'g')
  let text = substitute(text, '</\?pre>\c', '', 'g')
  let text = substitute(text, '<a .\{-}>\c', '', 'g')
  let text = substitute(text, '</a>', '', 'g')
  let text = substitute(text, '&quot;\c', '"', 'g')
  let text = substitute(text, '&amp;\c', '&', 'g')
  let text = substitute(text, '&lt;\c', '<', 'g')
  let text = substitute(text, '&gt;\c', '>', 'g')

  return text
endfunction " }}}

" InCssBlock() {{{
" Determines if the cusor is inside of <style> tags.
function! eclim#html#util#InCssBlock ()
  let line = line('.')

  let stylestart = search('<style\>', 'bcWn')
  if stylestart > 0
    let styleend = search('</style\s*>', 'bcWn', line('w0'))
  endif
  if stylestart > 0 && stylestart < line &&
      \ (styleend == 0 || (styleend > stylestart && line < styleend))
    return stylestart
  endif

  return 0
endfunction " }}}

" InJavascriptBlock() {{{
" Determines if the cursor is inside of <script> tags.
function! eclim#html#util#InJavascriptBlock ()
  let line = line('.')

  let scriptstart = search('<script\>', 'bcWn')
  if scriptstart > 0
    let scriptend = search('</script\s*>', 'bcWn', line('w0'))
  endif
  if scriptstart > 0 && scriptstart < line &&
        \ (scriptend == 0 || (scriptend > scriptstart && line < scriptend))
    return scriptstart
  endif

  return 0
endfunction " }}}

" OpenInBrowser(file) {{{
function! eclim#html#util#OpenInBrowser (file)
  let file = a:file
  if file == ''
    let file = expand('%:p')
  else
    let file = getcwd() . '/' . file
  endif
  let url = 'file://' . file
  call eclim#web#OpenUrl(url)
endfunction " }}}

" UrlEncode(string) {{{
function! eclim#html#util#UrlEncode (string)
  let result = a:string

  " must be first
  let result = substitute(result, '%', '%25', 'g')

  let result = substitute(result, '\s', '%20', 'g')
  let result = substitute(result, '!', '%21', 'g')
  let result = substitute(result, '"', '%22', 'g')
  let result = substitute(result, '#', '%23', 'g')
  let result = substitute(result, '\$', '%24', 'g')
  let result = substitute(result, '&', '%26', 'g')
  let result = substitute(result, "'", '%27', 'g')
  let result = substitute(result, '(', '%28', 'g')
  let result = substitute(result, ')', '%29', 'g')
  let result = substitute(result, '*', '%2A', 'g')
  let result = substitute(result, '+', '%2B', 'g')
  let result = substitute(result, ',', '%2C', 'g')
  let result = substitute(result, '-', '%2D', 'g')
  let result = substitute(result, '\.', '%2E', 'g')
  let result = substitute(result, '\/', '%2F', 'g')
  let result = substitute(result, ':', '%3A', 'g')
  let result = substitute(result, ';', '%3B', 'g')
  let result = substitute(result, '<', '%3C', 'g')
  let result = substitute(result, '=', '%3D', 'g')
  let result = substitute(result, '>', '%3E', 'g')
  let result = substitute(result, '?', '%3F', 'g')
  let result = substitute(result, '@', '%40', 'g')
  let result = substitute(result, '[', '%5B', 'g')
  let result = substitute(result, '\\', '%5C', 'g')
  let result = substitute(result, ']', '%5D', 'g')
  let result = substitute(result, '\^', '%5E', 'g')
  let result = substitute(result, '`', '%60', 'g')
  let result = substitute(result, '{', '%7B', 'g')
  let result = substitute(result, '|', '%7C', 'g')
  let result = substitute(result, '}', '%7D', 'g')
  let result = substitute(result, '\~', '%7E', 'g')

  return result
endfunction " }}}

" vim:ft=vim:fdm=marker
