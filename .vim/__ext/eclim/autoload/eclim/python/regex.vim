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

" Evaluate(file) {{{
function eclim#python#regex#Evaluate (file)
python << EOF
import StringIO, re, vim

def run (regex, text, lnum):
  """
  Run the regular expression against the supplied text and return list of
  matches and corresponding groups.

  match_lstart:match_cstart-match_lend:match_cend|group_lstart:group_cstart-group_lend:group_cend|...
  match_lstart:match_cstart-match_lend:match_cend|group_lstart:group_cstart-group_lend:group_cend|...

  Ex.
    2:14-2:17|2:16-2:17
    2:28-2:31|2:30-2:31
    3:29-3:32|3:31-3:32
    4:1-4:4|4:3-4:4
  """
  pattern = re.compile(regex)
  results = []
  for match in pattern.finditer(text):
    string = StringIO.StringIO()
    string.write('%s-%s' % \
      (linecol(lnum, match.start() + 1), linecol(lnum, match.end())))
    if(match.groups()):
      for ii in range(1, len(match.groups()) + 1):
        string.write('|%s-%s' % \
          (linecol(lnum, match.start(ii) + 1), linecol(lnum, match.end(ii))))
    results.append(string.getvalue())

  return results


def compileOffsets (text):
  """
  Compile a list of ending offsets for each line.
  """
  lines = text.strip().split('\n')
  offset, offsets = 0, [0]
  for line in lines:
    offset += len(line) + 1
    offsets.append(offset)
  return offsets


def linecol (lnum, offset):
  """
  Translate the supplied offset to a line column string.
  """
  if lnum:
    return '%i:%i' % (lnum, offset)

  line, col = 0, offset
  for entry in offsets:
    if offset > entry:
      line += 1
    else:
      col = offset - offsets[line - 1]
      break
  return '%i:%i' % (line + 1, col)


# process the file
type = vim.eval('exists("b:eclim_regex_type") ? b:eclim_regex_type : "file"')
file = open(vim.eval('a:file'))
try:
  regex, text = file.read().split('\n', 1)
  if not type or type == 'file':
    offsets = compileOffsets(text)
    vim.command("let results = '%s'" % '\n'.join(run(regex, text, 0)))
  else:
    results = []
    lnum = 1
    for line in text.split('\n'):
      lnum += 1
      results += run(regex, line, lnum)
    vim.command("let results = '%s'" % '\n'.join(results))
finally:
  file.close()
EOF
  return results
endfunction " }}}

" vim:ft=vim:fdm=marker
