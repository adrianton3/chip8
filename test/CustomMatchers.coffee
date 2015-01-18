'use strict'

CustomMatchers = {}

CustomMatchers.toThrowWithMessage = (util, customEqualityTesters) ->
  compare: (actual, expected) ->
    result = {}

    try
      actual()
      result.pass = false
      result.message = 'Expected function to throw an exception'
    catch ex
      if ex.message != expected.message ? expected
        result.pass = false
        result.message = """
            Expected function to throw an exception with the message '#{expected.message ? expected}'
            but instead received #{if ex.message? then "'#{ex.message}'" else 'no message'}
          """
      else if expected.coords? and (ex.coords.line != expected.coords.line or ex.coords.column != expected.coords.column)
        result.pass = false
        result.message = """
            Expected function to throw an exception at line #{expected.coords.line}, column #{expected.coords.column}
            but instead cereived exception at line #{ex.coords.line}, column #{ex.coords.column}
          """
      else
        result.pass = true

    result

window.CustomMatchers = CustomMatchers