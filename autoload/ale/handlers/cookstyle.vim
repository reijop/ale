call ale#Set('chef_cookstyle_options', '')
call ale#Set('chef_cookstyle_executable', 'cookstyle')

function! ale#handlers#cookstyle#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'chef_cookstyle_executable')
endfunction
