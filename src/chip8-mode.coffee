'use strict'

ace.define 'ace/mode/chip8', (require_, exports, module) ->
  oop = require_ 'ace/lib/oop'
  TextMode = require_('./text').Mode
  Tokenizer = require_('ace/tokenizer').Tokenizer
  HighlightRules = require_('ace/mode/chip8-rules').Chip8HighlightRules

  Mode = ->
    @$tokenizer = new Tokenizer new HighlightRules().getRules()
    return

  oop.inherits Mode, TextMode

  exports.Mode = Mode;
  return