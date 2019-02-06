# from http://howistart.org/posts/nim/1/

import macros

proc compile(code: string): NimNode {.compiletime.} =
  var stmts = @[newStmtList()]

  template addStmt(text): typed =
    stmts[stmts.high].add parseStmt(text)

  addStmt "var tape: array[1_000_000, char]"
  addStmt "var tapePos = 0"

  addStmt "{.push overflowchecks: off.}"
  addStmt "proc xinc(c: var char) = inc c"
  addStmt "proc xdec(c: var char) = dec c"
  addStmt "{.pop.}"
    
  for c in code:
    case c
    of '+': addStmt "xinc tape[tapePos]"
    of '-': addStmt "xdec tape[tapePos]"
    of '>': addStmt "inc tapePos"
    of '<': addStmt "dec tapePos"
    of '.': addStmt "stdout.write tape[tapePos]"
    of ',': addStmt "tape[tapePos] = stdin.readChar"
    of '[': stmts.add newStmtList()
    of ']':
      var loop = newNimNode(nnkWhileStmt)
      loop.add parseExpr("tape[tapePos] != '\\0'")
      loop.add stmts.pop
      stmts[stmts.high].add loop
    else: discard

  result = stmts[0]
  echo result.repr


when isMainModule:
  import os

  static:
    var code = compile "+>+[-]>,."
    
    dumpTree(code)


macro compileString*(code: string): typed =
  ## Compiles the brainfuck `code` string into Nim code that reads from stdin
  ## and writes to stdout.
  compile code.strval

macro compileFile*(filename: string): typed =
  ## Compiles the brainfuck code read from `filename` at compile time into Nim
  ## code that reads from stdin and writes to stdout.
  compile staticRead(filename.strval)

