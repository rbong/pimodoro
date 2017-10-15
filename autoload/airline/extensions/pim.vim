function! airline#extensions#pim#init(ext)
  call a:ext.add_statusline_funcref(function('airline#extensions#pim#apply'))
endfunction

function! airline#extensions#pim#apply(...)
  let w:airline_section_c = get(w:, 'airline_section_c', g:airline_section_c)
  let w:airline_section_c .= g:airline_left_sep . ' %{pim#get()}'
endfunction
