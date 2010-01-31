" Author:  Eric Van Dewoestine
" Version: $Revision$
"
" Description: {{{
"   see http://eclim.sourceforge.net/vim/javascript/validate.html
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
if !exists("g:EclimJavascriptValidate")
  let g:EclimJavascriptValidate = 1
endif
" }}}

if g:EclimJavascriptValidate
  augroup eclim_javascript_validate
    autocmd!
    autocmd BufWritePost *.js call eclim#javascript#validate#Validate(1)
  augroup END
endif

" Command Declarations {{{
if !exists(":Validate")
  command -nargs=0 -buffer Validate :call eclim#javascript#validate#Validate(0)
endif
" }}}

" vim:ft=vim:fdm=marker
