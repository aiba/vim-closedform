
# vim-closedform

Vim plugin to automatically close open lisp forms.  I wrote this for editing
clojure code.

For example, if you type "({[", then call AppendClosingFormSymbol 3
times, it will insert "]", "}", and ")" in order.

There's also AppendAllClosingFormSymbols which will close all open
forms before the cursor.  Typing "({[" then calling
AppendAllClosingFormSymbols will appen "]})".

I map this to M-; by adding this to my .vimrc:

```vim
imap <M-;> <Esc>:AppendClosingFormSymbol<CR>a
nmap <M-;> <Esc>:AppendClosingFormSymbol<CR>
```

