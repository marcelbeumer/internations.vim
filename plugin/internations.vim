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
      setlocal suffixesadd+=.less
      setlocal path+=**
  endfunction

  function! JavaScriptSettings()
    setlocal suffixesadd+=.js
    setlocal suffixesadd+=.es.js
    let bundlePath = simplify(g:internations_root . '/app-new/src/InterNations/Bundle/LayoutBundle/Resources/public/frontend/js/')
    exec 'setlocal path+=' . bundlePath
    let g:neomake_javascript_enabled_makers = ['eslint_d']

    if expand('%:t') =~ '.es.js'
      let g:neomake_javascript_eslint_d_maker = {
        \ 'args': ['-f', 'compact',
          \ '-c', simplify(g:internations_root . '/.eslintrc_es6'),
          \ '--rulesdir', simplify(g:internations_root) . '/eslint_rules'
          \ ],
        \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
        \ '%W%f: line %l\, col %c\, Warning - %m'
        \ }
    else
      let g:neomake_javascript_eslint_d_maker = {
        \ 'args': ['-f', 'compact',
          \ '--rulesdir', simplify(g:internations_root . '/eslint_rules')
          \ ],
        \ 'errorformat': '%E%f: line %l\, col %c\, Error - %m,' .
        \ '%W%f: line %l\, col %c\, Warning - %m'
        \ }
    endif
  endfunction

  autocmd BufEnter *.js call JavaScriptSettings()
  autocmd FileType jinja call HTMLTwigSettings()
  nmap <leader>g :call EditIncludeOnLine()<cr>
endif
