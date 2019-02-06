import brainfuckpkg/interpreter
import brainfuckpkg/compiler

when isMainModule:
  import os
  
  echo "Welcome to brainfuck"
 
  let code = if paramCount() > 0: readFile paramStr(1)
             else: readAll stdin

  interpret code

