if exists("g:loaded_fillstruct")
  finish
endif
let g:fillstruct = 1
let s:save_cpo = &cpo
set cpo&vim

function s:CheckBinary()
  if !executable('fillstruct')
    echo 'fillstruct not found'
    return -1
  endif
endfunction

let err = s:CheckBinary()
if err != 0
  finish
endif

let &cpo = s:save_cpo
unlet s:save_cpo
