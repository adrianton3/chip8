'use strict'

ace.define 'ace/mode/chip8-rules', (require_, exports, module) ->
  oop = require_('../lib/oop')
  TextHighlightRules = require_('./text_highlight_rules').TextHighlightRules

  Chip8HighlightRules = ->
    INSTRUCTION = 'keyword'
    REGISTER = 'variable'
    NUMBER = 'constant.other'
    COMMENT = 'comment'
    PLAIN = 'text'

    @$rules =
      'start': [{
        token: INSTRUCTION
        regex: ///
            addi|addr|and|bcd|call|cls|digit|dw|iaddr|imovi|jumpoff|jump|load|movi|movr|movs|movt|nsubr|
            or|return|rmovt|rnd|sei|ser|shl|shr|skr|snei|snkr|sner|sprite|store|subr|waitk|xor
          ///
      }, {
        token: REGISTER
        regex: /v[0-9A-Fa-f]/
      }, {
        token: NUMBER
        regex: /0x[\dA-Fa-f]+/
      }, {
        token: NUMBER
        regex: /0b[01]+/
      }, {
        token: NUMBER
        regex: /\d+(?= |$)/
      }, {
        token: PLAIN
        regex: /[\w\-_:]+/
      }, {
        token: COMMENT
        regex: /;.*/
      }]

    return

  oop.inherits Chip8HighlightRules, TextHighlightRules
  exports.Chip8HighlightRules = Chip8HighlightRules
  return

return
