if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

function! InsertClosingFormSymbol()
python << EOF
import vim

# vim.current.window.cursor - get the cursor position as (row, col) (row is 1-based, col is 0-based)
# vim.current.buffer - a list of the lines in the current buffer (0-based, unfortunately)

#l = vim.current.line - 1 # 0-based.
(l,c) = vim.current.window.cursor
(l,c) = (l-1,c)
lstr = vim.current.buffer[l]

vim.current.buffer[l] = lstr[:c+1] + ')' + lstr[c+1:]
vim.current.window.cursor = (l+1,c+1)

EOF
" Here the python code is closed. We can continue writing VimL or python again.
endfunction

command! -nargs=0 InsertClosingFormSymbol call InsertClosingFormSymbol()

" for testing:
call InsertClosingFormSymbol()

