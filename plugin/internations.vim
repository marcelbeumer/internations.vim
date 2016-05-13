if exists('g:loaded_internations')
  finish
endif
let g:loaded_internations = 1

if getcwd() =~ g:internations_root

  function! EditIncludeOnLine()
    let line = getline('.')
    if exists("b:edit_include_line_parser")
      let GrabFn = function(b:edit_include_line_parser)
      let line = call(GrabFn, [line])
    endif
    let path = line
    if exists("b:edit_include_path_resolver")
      let ResolveFn = function(b:edit_include_path_resolver)
      let path = call(ResolveFn, [line])
    endif
    let path = findfile(path)
    exec 'e ' . path
  endfunction

  function! DefaultIncludeLineParser(line)
    return substitute(a:line, '.\{-}[''"]\(.\{-}\)[''"].*', '\1', 'g')
  endfunction

  function! EditIncludeBufferSetup(pathResolver, lineParser)
    let lineParser = 'DefaultIncludeLineParser'
    if strlen(a:lineParser) > 0
      let lineParser = a:lineParser
    endif
    exec 'let b:edit_include_line_parser=''' . lineParser . ''''
    if strlen(a:pathResolver) > 0
      exec 'let b:edit_include_path_resolver=''' . a:pathResolver . ''''
      exec 'setlocal includeexpr=' . a:pathResolver . '(v:fname)'
    endif
  endfunction

  function! TwigEditIncludePathResolver(fname)
    let fname = a:fname
    let fname = substitute(fname, ':', '/', 'g')
    let fname = substitute(fname, '^InterNations\(.\{-}\)Bundle', '\1Bundle/Resources/views/', 'g')
    return fname
  endfunction

  function! HTMLTwigSettings()
    call EditIncludeBufferSetup('TwigEditIncludePathResolver', '')
    exec 'setlocal path+=' . simplify(g:internations_root . '/app-new/src/InterNations/Bundle')
  endfunction

  function! JavaScriptLocalSettings()
    setlocal suffixesadd+=.js
    setlocal suffixesadd+=.es.js
    exec 'setlocal path+=' .
      \ simplify(g:internations_root .
      \ '/app-new/src/InterNations/Bundle/LayoutBundle/Resources/public/frontend/js/')
  endfunction

  function! JavaScriptGlobalSettings()
    let g:neomake_javascript_enabled_makers = ['eslint_d']
    let g:neomake_javascript_eslint_d_maker = {
      \ 'args': ['-f', 'compact',
        \ '--rulesdir', simplify(g:internations_root . '/eslint_rules')
        \ ],
      \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
      \ '%W%f: line %l\, col %c\, Warning - %m'
      \ }
  endfunction

  autocmd FileType jinja call HTMLTwigSettings()
  autocmd FileType javascript call JavaScriptLocalSettings()
  autocmd BufEnter *.js call JavaScriptGlobalSettings()
  nmap <leader>g :call EditIncludeOnLine()<cr>

  let g:ctrlp_user_command = ['.git', 'git ls-files %s --exclude-standard | grep -vE "node_modules|vendor/|web/"', 'find %s -type f']
  let g:ctrlp_lazy_update = 100
endif
