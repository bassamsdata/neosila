- Reorganize the configuration files
- choose custom random colorschem every time nvim starts
- check wich plugin makes the crolling bad

# make this modules:
- usage time
- snowflakes
- Auto save if diagnostics.count() is nil. (see n-macro for this)

## make this into small module:
https://stackoverflow.com/questions/11634804/vim-auto-resize-focused-window
:let &winheight = &lines * 7 / 10
:autocmd WinEnter * execute winnr() * 2 . 'wincmd _'
https://stackoverflow.com/questions/61243238/how-do-i-make-window-splits-maintain-consistent-sizing-with-the-current-as-large
https://github.com/kwkarlwang/bufresize.nvim/blob/master/lua/bufresize.lua
