let s:cpo_save = &cpo
set cpo&vim

function! fillstruct#FillStruct() abort
  let l:cmd = 'fillstruct' . ' -file ' . bufname('') . ' -offset ' . s:offset(line('.'), col('.')) . ' -line '. line('.')

  if &modified
    let l:cmd = l:cmd . ' -modified'
    let l:buffer = join(s:getLines(), "\n")
    let l:out = system(l:cmd, expand("%:p:gs!\\!/!") . "\n" . strlen(l:buffer) . "\n" . l:buffer)
  else
    let l:out = system(l:cmd)
  endif
  try
    let l:json = json_decode(l:out)
  catch
    echomsg l:out
    return
  endtry

  let l:pos = getpos('.')

  try
    for l:struct in l:json
      let l:code = split(l:struct['code'], "\n")

      exe l:struct['start'] . 'go'
      let l:code[0] = getline('.')[:col('.')-1] . l:code[0]
      exe l:struct['end'] . 'go'
      let l:code[len(l:code)-1] .= getline('.')[col('.'):]

      let l:indent = repeat("\t", indent('.') / &tabstop)
      for l:i in range(1, len(l:code)-1)
        let l:code[l:i] = l:indent . l:code[l:i]
      endfor

      exe 'normal! ' . l:struct['start'] . 'gov' . l:struct['end'] . 'gox'
      " ... in with the new.
      call setline('.', l:code[0])
      call append('.', l:code[1:])
    endfor
  finally
    call setpos('.', l:pos)
  endtry
endfunction

function! s:offset(line, col) abort
  if &encoding != 'utf-8'
    let sep = s:lineEnding()
    let buf = a:line == 1 ? '' : (join(getline(1, a:line-1), sep) . sep)
    let buf .= a:col == 1 ? '' : getline('.')[:a:col-2]
    return len(iconv(buf, &encoding, 'utf-8'))
  endif
  return line2byte(a:line) + (a:col-2)
endfunction

function! s:lineEnding() abort
  if &fileformat == 'mac'
    return "\r"
  endif
  return "\n"
endfunction

function! s:getLines()
  let l:buf = getline(1, '$')
  if &encoding != 'utf-8'
    let l:buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
  endif
  return l:buf
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
