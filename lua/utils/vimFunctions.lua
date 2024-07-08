vim.cmd([[
  function TextObjectAll()
    let g:restore_position = winsaveview()
    normal! ggVG

    if index(['c','d'], v:operator) == 1
      " For delete/change ALL, we don't wish to restore cursor position.
    else
      call feedkeys("\<Plug>(RestoreView)")
    end

  endfunction
]])
