" Author:  Eric Van Dewoestine
" Version: $Revision$
"
" Description: {{{
"   Extension to default css syntax to fix issues.
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

source $VIMRUNTIME/syntax/css.vim

" fix issue where vim's css syntax file has issues if a curly immediately
" follows a psudo class
" Ex.
" a:hover{
"   color: #fff;
" }
syn match cssPseudoClass ":[^ {]*" contains=cssPseudoClassId,cssUnicodeEscape

" vim:ft=vim:fdm=marker
