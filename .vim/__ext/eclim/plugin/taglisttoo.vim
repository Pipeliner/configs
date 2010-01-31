" Author:  Eric Van Dewoestine
" Version: $Revision$
"
" Description: {{{
"   see http://eclim.sourceforge.net/vim/taglist.html
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

" TaglistToo {{{
if exists('g:taglisttoo_loaded') || exists(":Tlist") ||
   \ (exists('g:taglisttoo_disabled') && g:taglisttoo_disabled)
  finish
endif
let g:taglisttoo_loaded = 1

" Global Variables {{{

" Automatically open the taglist window on Vim startup
if !exists('g:Tlist_Auto_Open')
  let g:Tlist_Auto_Open = 0
endif

if !exists('g:Tlist_Ctags_Cmd')
  if executable('exuberant-ctags')
    let g:Tlist_Ctags_Cmd = 'exuberant-ctags'
  elseif executable('ctags')
    let g:Tlist_Ctags_Cmd = 'ctags'
  elseif executable('ctags.exe')
    let g:Tlist_Ctags_Cmd = 'ctags.exe'
  elseif executable('tags')
    let g:Tlist_Ctags_Cmd = 'tags'
  endif
endif

let TagList_title = "__Tag_List__"

if g:Tlist_Auto_Open
  autocmd VimEnter * nested call eclim#taglist#taglisttoo#AutoOpen()
  " Auto open on new tabs as well.
  if v:version >= 700
    autocmd BufWinEnter *
      \ if tabpagenr() > 1 && !exists('t:Tlist_Auto_Opened') |
      \   call eclim#taglist#taglisttoo#AutoOpen() |
      \   let t:Tlist_Auto_Opened = 1 |
      \ endif
  endif
endif
" }}}

" Command Declarations {{{
if !exists(":TlistToo")
  command TlistToo :call eclim#taglist#taglisttoo#Taglist()
endif
" }}}

" }}}

" Eclim groovy enhanced settings for taglist or taglisttoo {{{

" Global Variables {{{
if !exists("g:EclimTaglistEnabled")
  let g:EclimTaglistEnabled = 1
endif

" first check if user has taglist plugin, wants the eclim enhancement, and
" eclimd is running
if !exists("g:Tlist_Ctags_Cmd") || !g:EclimTaglistEnabled || !eclim#PingEclim(0)
  finish
endif

" set command for taglist.vim
let g:Tlist_Ctags_Cmd =
  \ eclim#GetEclimCommand() . ' -command taglist -c "' . g:Tlist_Ctags_Cmd . '"'
" for windows, need to add a trailing quote to complete the command.
if g:Tlist_Ctags_Cmd =~ '^"[a-zA-Z]:'
  let g:Tlist_Ctags_Cmd = g:Tlist_Ctags_Cmd . '"'
endif

" }}}

" Taglist Settings {{{
" taglist.vim settings
if !exists(':TlistToo')
  if !exists("g:tlist_ant_settings")
    let g:tlist_ant_settings = 'ant;p:project;i:import;r:property;t:target'
  endif

  if !exists("g:tlist_commonsvalidator_settings")
    let g:tlist_commonsvalidator_settings = 'commonsvalidator;c:constant;f:form'
  endif

  if !exists("g:tlist_dtd_settings")
    let g:tlist_dtd_settings = 'dtd;e:element'
  endif

  if !exists("g:tlist_forrestdocument_settings")
    let g:tlist_forrestdocument_settings = 'forrestdocument;s:section'
  endif

  if !exists("g:tlist_forreststatus_settings")
    let g:tlist_forreststatus_settings = 'forreststatus;t:todo;r:release'
  endif

  if !exists("g:tlist_hibernate_settings")
    let g:tlist_hibernate_settings = 'hibernate;t:typedef;f:filter-def;i:import;q:query;s:sql-query;c:class;j:joined-subclass'
  endif

  if !exists("g:tlist_html_settings")
    let g:tlist_html_settings = 'html;a:anchor;i:id;f:function'
  endif

  if !exists("g:tlist_htmldjango_settings")
    let g:tlist_htmldjango_settings = 'htmldjango;a:anchor;i:id;f:function'
  endif

  if !exists("g:tlist_javascript_settings")
    let g:tlist_javascript_settings = 'javascript;f:function'
  endif

  if !exists("g:tlist_junitresult_settings")
    let g:tlist_junitresult_settings = 'junitresult;t:testcase;o:output'
  endif

  if !exists("g:tlist_jproperties_settings")
    let g:tlist_jproperties_settings = 'jproperties;p:property'
  endif

  if !exists("g:tlist_log4j_settings")
    let g:tlist_log4j_settings = 'log4j;a:appender;c:category;l:logger;r:root'
  endif

  if !exists("g:tlist_php_settings")
    let g:tlist_php_settings = 'php;i:interface;c:class;f:function'
  endif

  if !exists("g:tlist_spring_settings")
    let g:tlist_spring_settings = 'spring;i:import;a:alias;b:bean'
  endif

  if !exists("g:tlist_sql_settings")
    let g:tlist_sql_settings = 'sql;g:group / role;r:role;u:user;m:user;p:tablespace;z:tablespace;s:schema;t:table;v:view;q:sequence;x:trigger;f:function;c:procedure'
  endif

  if !exists("g:tlist_tld_settings")
    let g:tlist_tld_settings = 'tld;t:tag'
  endif

  if !exists("g:tlist_webxml_settings")
    let g:tlist_webxml_settings = 'webxml;p:context-param;f:filter;i:filter-mapping;l:listener;s:servlet;v:servlet-mapping'
  endif

  if !exists("g:tlist_wsdl_settings")
    let g:tlist_wsdl_settings = 'wsdl;t:types;m:messages;p:ports;b:bindings'
  endif

  if !exists("g:tlist_xsd_settings")
    let g:tlist_xsd_settings = 'xsd;e:elements;t:types'
  endif

" taglisttoo.vim settings
else
  if !exists("g:tlist_ant_settings")
    let g:tlist_ant_settings = {
        \ 'p': 'project',
        \ 'i': 'import',
        \ 'r': 'property',
        \ 't': 'target'
      \ }
  endif

  if !exists("g:tlist_commonsvalidator_settings")
    let g:tlist_commonsvalidator_settings = {'c': 'constant', 'f': 'form'}
  endif

  if !exists("g:tlist_dtd_settings")
    let g:tlist_dtd_settings = {'e': 'element'}
  endif

  if !exists("g:tlist_forrestdocument_settings")
    let g:tlist_forrestdocument_settings = {'s': 'section'}
  endif

  if !exists("g:tlist_forreststatus_settings")
    let g:tlist_forreststatus_settings = {'t': 'todo', 'r': 'release'}
  endif

  if !exists("g:tlist_hibernate_settings")
    let g:tlist_hibernate_settings = {
        \ 't': 'typedef',
        \ 'f': 'filter-def',
        \ 'i': 'import',
        \ 'q': 'query',
        \ 's': 'sql-query',
        \ 'c': 'class',
        \ 'j': 'joined-subclass'
      \ }
  endif

  if !exists("g:tlist_html_settings")
    let g:tlist_html_settings = {'a': 'anchor', 'i': 'id', 'f': 'function'}
  endif

  if !exists("g:tlist_htmldjango_settings")
    let g:tlist_htmldjango_settings = {'a': 'anchor', 'i': 'id', 'f': 'function'}
  endif

  if !exists("g:tlist_javascript_settings")
    let g:tlist_javascript_settings = {'o': 'object', 'f': 'function'}
  endif

  if !exists("g:tlist_junitresult_settings")
    let g:tlist_junitresult_settings = {'t': 'testcase', 'o': 'output'}
  endif

  if !exists("g:tlist_jproperties_settings")
    let g:tlist_jproperties_settings = {'p': 'property'}
  endif

  if !exists("g:tlist_log4j_settings")
    let g:tlist_log4j_settings = {
        \ 'a': 'appender',
        \ 'c': 'category',
        \ 'l': 'logger',
        \ 'r': 'root',
      \ }
  endif

  if !exists("g:tlist_php_settings")
    let g:tlist_php_settings = {
        \ 'i': 'interface',
        \ 'c': 'class',
        \ 'f': 'function',
      \ }
  endif

  if !exists("g:tlist_spring_settings")
    let g:tlist_spring_settings = {'i': 'import', 'a': 'alias', 'b': 'bean'}
  endif

  if !exists("g:tlist_sql_settings")
    let g:tlist_sql_settings = {
        \ 'g': 'group / role',
        \ 'r': 'role',
        \ 'u': 'user',
        \ 'm': 'user',
        \ 'p': 'tablespace',
        \ 'z': 'tablespace',
        \ 's': 'schema',
        \ 't': 'table',
        \ 'v': 'view',
        \ 'q': 'sequence',
        \ 'x': 'trigger',
        \ 'f': 'function',
        \ 'c': 'procedure'
      \ }
  endif

  if !exists("g:tlist_tld_settings")
    let g:tlist_tld_settings = {'t': 'tag'}
  endif

  if !exists("g:tlist_webxml_settings")
    let g:tlist_webxml_settings = {
        \ 'p': 'context-param',
        \ 'f': 'filter',
        \ 'i': 'filter-mapping',
        \ 'l': 'listener',
        \ 's': 'servlet',
        \ 'v': 'servlet-mapping'
      \ }
  endif

  if !exists("g:tlist_wsdl_settings")
    let g:tlist_wsdl_settings = {
        \ 't': 'types',
        \ 'm': 'messages',
        \ 'p': 'ports',
        \ 'b': 'bindings'
      \ }
  endif

  if !exists("g:tlist_xsd_settings")
    let g:tlist_xsd_settings = {'e': 'elements', 't': 'types'}
  endif
endif
" }}}

" }}}

" vim:ft=vim:fdm=marker
