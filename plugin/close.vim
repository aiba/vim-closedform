if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! AppendClosingFormSymbol()
python << EOF
import vim

# vim.current.window.cursor - get the cursor position as (row, col) (row is 1-based, col is 0-based)
# vim.current.buffer - a list of the lines in the current buffer (0-based, unfortunately)

def log(s):
  open("/tmp/log", "a").write(s)

CHARPAIRS = [
  ('(', ')'),
  ('[', ']'),
  ('{', '}'),
  ]

def char_pair(char):
  for p in CHARPAIRS:
    if p[0]==char:
      return p[1]
    if p[1]==char:
      return p[0]
  return None

def is_opener(char):
  return (0 < len([x for x in CHARPAIRS if x[0]==char]))

def is_closer(char):
  return (0 < len([x for x in CHARPAIRS if x[1]==char]))

def append_char(char):
  (l,c) = vim.current.window.cursor
  (l,c) = (l-1,c)
  lstr = vim.current.buffer[l]
  vim.current.buffer[l] = lstr[:c+1] + str(char) + lstr[c+1:]
  vim.current.window.cursor = (l+1,c+1)

def buffer_until_cursor():
  (current_line, current_col) = vim.current.window.cursor
  current_line -= 1 # make 0-based
  return ("\n".join(vim.current.buffer[0:current_line]
                    + [vim.current.buffer[current_line][0:current_col+1]])
                 + "\n")

def form_stack():
  s = buffer_until_cursor()
  i=0
  in_str=False
  stack = []
  while (i != -1) and (i < len(s)):
    c=s[i]
    if c=='\\':
      i += 2
      continue
    if c=='"':
      in_str = not in_str
      i += 1
      continue
    if not in_str:
      if c==';':
        i = s.find('\n', i) # skip to end of line
        continue
      if is_opener(c):
        stack.append(c)
      if is_closer(c):
        if (len(stack) > 0) and (c == char_pair(stack[-1])):
          stack.pop()
    i += 1
    continue
  return stack

stack=form_stack()
if len(stack) > 0:
  append_char(char_pair(stack[-1]))
else:
  print "No open forms."

# TODO:
#   ignore things inside strings
#   ignore clojure ; comments
#   handle \[ as character, not formchar
#   test at end of really large file.
#   cleanup code
#   write AppendAllClosingFormSymbols to repeatedly call AppendClosingFormSymbol
#   documentation

EOF
" Here the python code is closed. We can continue writing VimL or python again.
endfunction

command! -nargs=0 AppendClosingFormSymbol call AppendClosingFormSymbol()

" for testing:
"imap <M-;> <Esc>:AppendClosingFormSymbol<CR>a
"nmap <M-;> <Esc>:AppendClosingFormSymbol<CR>

