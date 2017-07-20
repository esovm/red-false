; false.red
Red []

s: stack: []

print-stack: does []
print-read: does []
; print-stack: does [prin "stack: " print s]
; print-read: function[a][prin {read: } a]

pop: does [h: take s]
push: function[a][insert s a]

digit: charset "0123456789"
number: [copy n [some digit] (print-read n push load n)]

; +: :add ; creates hell on console
; *: :multiply

; symbol: [copy op ["+" | "*"] (print get-word op insert s add take s take s)]
; "+" "-" "*" "/" "_"
op: [ "+" (push add pop pop)
    | "-" (push subtract pop pop) 
    | "*" (push multiply pop pop) 
    | "/" (push divide pop pop) 
    | "_" (push negate pop) ]

; "="	">"
tf: function[v][either ((v = true) or (v = -1)) [-1][0]]

; bool: [ "=" (t: equal? pop pop push (tf t))
bool: [ "=" (push tf equal? pop pop)
      | ">" (push tf (lesser? pop pop))
      | "~" (push tf (complement pop))
      | "&" (push tf (and~ pop pop)) 
      | "|" (push tf (or~ pop pop)) ]

value: ["'" set val skip (push to-integer val)]

lower: charset [#"a" - #"z"]
variable: [ copy var lower [ 
            ":" (set load var pop) | 
            ";" (push get load var)
            ]]

lambda: [ "[" copy f to "]" skip (push f)] ; push the expression as-is to the stack
apply: [ "!" (f: pop parse f false-lang)]  ; execute from the head as if it was read from original string

stack-functions: [ "$" (push pick s 1)      
                 | "%" (pop)                 
                 | "\" (swap s next s)       
                 | "@" (swap s next s swap s next next s)
                 | "ø" (push pick s 1 + pop) ]

false-lang: [any [[space | number | op | bool | value | variable | lambda | apply | stack-functions] (print-stack)] ]

fac: {[$1=$[\%1\]?~[$1-f;!*]?]f:}
print parse fac false-lang

ex1: "1 2 + 4 *"
print parse ex1 false-lang
; print s/1

; test: does [a][print reduce [parse a false-lang]]
; test "12 + 3"
; print parse "1 1+" false-lang
; print parse "1 21+" false-lang

s: []
print parse "1 2 -" false-lang
; print s/1

s: []
print parse "1 _ " false-lang
; print s/1

s: []
print parse "3 6 / " false-lang
print s/1 = 2


; test: function[f /local s][print parse f false-lang print s]

test: function[f v][
    clear s 
    p: parse f false-lang 
    result: equal? v s/1
    print result

    ; prin { f: "} prin f print {"}
    ; prin { v: "} prin v print {"}
    ; prin { s/1: "} prin s/1 print {"}
    ; prin { equal? "} prin result print {"}
    ; prin newline
    ]

test-stack: function[f st][
    clear s 
    p: parse f false-lang 
    result: equal? st s
    print result

    ; prin { f: "} prin f print {"}
    ; prin { st: "} prin st print {"}
    ; prin { s: "} prin s print {"}
    ; prin { equal? "} prin result print {"}
    ; prin newline
    ]


; eq, greater
test "1 1 =" -1
test "1 0 >" -1

; ; not
test "1 0 =~" -1
test "1 0 = ~" -1

test "1 2 >" 0
test "1 2 > ~" -1

test "1 1 =~" 0

test "1 1 = 1 0 = |" -1

test "0  0  |" 0
test "1_ 0  |" -1
test "0  1_ |" -1
test "1_ 1_ |" -1

test "0  0  &" 0
test "1_ 0  &" 0
test "0  1_ &" 0
test "1_ 1_ &" -1

test "1_ ~" 0
test "0  ~" -1

test "'A" 65
test "' " 32
; test "1a:"      ; { a:=1 }
; test "a;1+b:"   ; { b:=a+1 }
test "1a:a;1+b:b;" 2
test "2[1+]!" 3

; [1+]i:
; 2i;!

test "[1+]i:2i;!" 3

test-stack "1$" [1 1]
test-stack "1 2%" [1]
test-stack "1 2\" [1 2]
test-stack "1 2 3" [3 2 1]
test-stack "1 2 3@" [1 3 2]
test-stack "7 8 9 2ø" [7 9 8 7]

