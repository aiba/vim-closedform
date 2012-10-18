if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! AppendClosingFormSymbol()
python << EOF
import vim

# vim.current.window.cursor - get the cursor position as (row, col) (row is 1-based, col is 0-based)
# vim.current.buffer - a list of the lines in the current buffer (0-based, unfortunately)

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

def reverse_buffer_char_list():
  result = []

  (current_line, current_col) = vim.current.window.cursor
  current_line = current_line-1 # make 0-based
  buf = vim.current.buffer

  for l in range(0,current_line+1):
    stop = len(buf[l])
    if l == current_line:
      stop = current_col+1
    result += list(buf[l][:stop])

  result.reverse()
  return result

def first_open_form_char(charlist):
  stack = []
  for c in charlist:
    if is_closer(c):
      stack.append(c)
    if is_opener(c):
      if (len(stack) > 0) and (c == char_pair(stack[-1])):
        stack.pop()
      else:
        return char_pair(c)
  return None

append_char(first_open_form_char(reverse_buffer_char_list()))

# TODO:
#   ignore things inside strings
#   ignore clojure ; comments
#   handle \[ as character, not formchar

EOF
" Here the python code is closed. We can continue writing VimL or python again.
endfunction

command! -nargs=0 AppendClosingFormSymbol call AppendClosingFormSymbol()

" for testing:
call AppendClosingFormSymbol()

