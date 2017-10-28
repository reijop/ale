" Author: ynonp - https://github.com/ynonp, Eddie Lebow https://github.com/elebow
" Description: cookstyle, a code style analyzer for Ruby files

function! ale_linters#chef#cookstyle#GetCommand(buffer) abort
    let l:executable = ale#handlers#cookstyle#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? 'chef'
    \   ? ' exec cookstyle'
    \   : ''

    return ale#Escape(l:executable) . l:exec_args
    \   . ' --format json --force-exclusion '
    \   . ale#Var(a:buffer, 'ruby_cookstyle_options')
    \   . ' --stdin ' . ale#Escape(expand('#' . a:buffer . ':p'))
endfunction

function! ale_linters#chef#cookstyle#Handle(buffer, lines) abort
    try
        let l:errors = json_decode(a:lines[0])
    catch
        return []
    endtry

    if !has_key(l:errors, 'summary')
    \|| l:errors['summary']['offense_count'] == 0
    \|| empty(l:errors['files'])
        return []
    endif

    let l:output = []

    for l:error in l:errors['files'][0]['offenses']
        let l:start_col = l:error['location']['column'] + 0
        call add(l:output, {
        \   'lnum': l:error['location']['line'] + 0,
        \   'col': l:start_col,
        \   'end_col': l:start_col + l:error['location']['length'] - 1,
        \   'text': printf('%s [%s]', l:error['message'], l:error['cop_name']),
        \   'type': ale_linters#chef#cookstyle#GetType(l:error['severity']),
        \})
    endfor

    return l:output
endfunction

function! ale_linters#chef#cookstyle#GetType(severity) abort
    if a:severity is? 'convention'
    \|| a:severity is? 'warning'
    \|| a:severity is? 'refactor'
        return 'W'
    endif

    return 'E'
endfunction

call ale#linter#Define('ruby', {
\   'name': 'cookstyle',
\   'executable_callback': 'ale#handlers#cookstyle#GetExecutable',
\   'command_callback': 'ale_linters#chef#cookstyle#GetCommand',
\   'callback': 'ale_linters#chef#cookstyle#Handle',
\})
