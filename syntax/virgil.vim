" Vim syntax file
" Language: Virgil (.v3)
" Latest Revision: 2026

if exists("b:current_syntax")
  finish
endif

" 1. Keywords (Declarations & Control Flow)
syntax keyword virgilKeyword def class component type var new super private public local
syntax keyword virgilStatement if else while for match return break continue case

" 2. Built-in Types & Constants
syntax keyword virgilType void int byte bool short long float double string
syntax keyword virgilType Array array Ref ref Range range
syntax keyword virgilBoolean true false
syntax keyword virgilConstant null this

"Virgil supports specific bit-width integers (e.g., i32, u8, i64)
syntax match virgilType "\v\<(i|u)[1-9][0-9]*\>"

" 3. Numbers
" Matches standard digits, optionally with u, L, or uL suffixes
syntax match virgilNumber "\v<\d+(u|U|l|L|uL|Ul|uL|UL)?>"
" Matches hex (e.g., 0x80000000u)
syntax match virgilNumber "\v<0x[0-9a-fA-F]+(u|U|l|L|uL|Ul|uL|UL)?>"

" 4. Strings & Characters
syntax region virgilString start=/"/ skip=/\\"/ end=/"/ contains=virgilSpecialChar
syntax match virgilSpecialChar "\\n\|\\r\|\\t\|\\\"" contained

" 5. Comments
" Single line comments start with //
syntax match virgilComment "//.*$" contains=virgilTodo
"Multi-line (block) comments start with /* and end with */
syntax region virgilComment start="/\*" end="\*/" contains=virgilTodo
syntax keyword virgilTodo TODO FIXME XXX contained

" 6. Link to Standard Neovim Highlight Groups
highlight default link virgilKeyword Keyword
highlight default link virgilStatement Statement
highlight default link virgilType Type
highlight default link virgilBoolean Boolean
highlight default link virgilConstant Constant
highlight default link virgilNumber Number
highlight default link virgilString String
highlight default link virgilSpecialChar SpecialChar
highlight default link virgilComment Comment
highlight default link virgilTodo Todo

let b:current_syntax = "virgil"
