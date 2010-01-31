" Author:  Eric Van Dewoestine
" Version: $Revision: 1677 $
"
" Description: {{{
"   see http://eclim.sourceforge.net/vim/wsdl/validate.html
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
if !exists("g:EclimWsdlValidate")
  let g:EclimWsdlValidate = 1
endif
" }}}

if g:EclimWsdlValidate
  augroup eclim_wsdl_validate
    autocmd!
    autocmd BufWritePost *.wsdl call eclim#common#validate#Validate('wsdl', 1)
  augroup END
endif

" disable plain xml validation.
augroup eclim_xml
  autocmd!
augroup END

" Command Declarations {{{
command! -nargs=0 -buffer Validate :call eclim#common#validate#Validate('wsdl', 0)
" }}}

" vim:ft=vim:fdm=marker
