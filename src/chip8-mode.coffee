'use strict'

ace.define 'ace/mode/chip8', (require_, exports, module) ->
  oop = require_ 'ace/lib/oop'
  TextMode = require_('./text').Mode
  Tokenizer = require_('ace/tokenizer').Tokenizer
  HighlightRules = require_('ace/mode/chip8-rules').Chip8HighlightRules

  Mode = ->
    @$tokenizer = new Tokenizer new HighlightRules().getRules()
    @$keywordList = '''
      addi|addr|and|bcd|call|cls|digit|dw|iaddr|imovi|jumpoff|jump|load|movi|movr|movs|movt|nsubr|
      or|return|rmovt|rnd|sei|ser|shl|shr|skr|snei|snkr|sner|sprite|store|subr|waitk|xor
    '''.split '|'

    return

  oop.inherits Mode, TextMode

  exports.Mode = Mode;
  return