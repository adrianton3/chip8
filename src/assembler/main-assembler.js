// Generated by CoffeeScript 1.8.0
(function() {
  'use strict';
  var app;

  app = angular.module('Assembler', []);

  app.controller('AssemblerController', function($scope) {
    var TICKS_PER_FRAME, assembler, chip8, draw, editor, errorLine, getState, initContext, keyboard, onChange, rafId, self, setVideoData, setupEditor, _ref;
    _ref = Chip8Renderer(), initContext = _ref.initContext, draw = _ref.draw, setVideoData = _ref.setVideoData;
    initContext(document.getElementById('can'));
    TICKS_PER_FRAME = 1;
    self = this;
    rafId = null;
    editor = null;
    errorLine = null;
    this.running = false;
    this.state = null;
    assembler = Chip8Assembler();
    keyboard = Chip8Keyboard();
    (document.getElementById('container')).appendChild(keyboard.getHtml());
    chip8 = Chip8();
    chip8.setKeyboard(keyboard);
    onChange = function(text) {
      var ex;
      if (text.length === 0) {
        editor.getSession().setAnnotations([]);
      } else {
        try {
          assembler.assemble(text);
          if (errorLine !== null) {
            editor.getSession().setAnnotations([]);
            errorLine = null;
          }
        } catch (_error) {
          ex = _error;
          if (ex.coords != null) {
            errorLine = ex.coords.line;
            editor.getSession().setAnnotations([
              {
                row: errorLine,
                text: ex.message,
                type: 'error'
              }
            ]);
          }
        }
      }
    };
    setupEditor = function() {
      editor = ace.edit('editor');
      editor.getSession().setMode('ace/mode/chip8');
      editor.setTheme('ace/theme/monokai');
      editor.on('input', function() {
        return onChange(editor.getValue());
      });
    };
    setupEditor();
    getState = function() {
      var I, programCounter, registers, stack, stackPointer;
      programCounter = chip8.getProgramCounter();
      stackPointer = chip8.getStackPointer();
      I = chip8.getI();
      registers = Array.prototype.slice.call(chip8.getRegisters(), 0);
      stack = Array.prototype.slice.call(chip8.getStack(), stackPointer);
      return {
        programCounter: programCounter,
        registers: registers,
        stackPointer: stackPointer,
        I: I,
        stack: stack
      };
    };
    this.start = function() {
      var mainLoop;
      this.reset();
      mainLoop = (function(_this) {
        return function() {
          var i, _i;
          for (i = _i = 0; 0 <= TICKS_PER_FRAME ? _i < TICKS_PER_FRAME : _i > TICKS_PER_FRAME; i = 0 <= TICKS_PER_FRAME ? ++_i : --_i) {
            chip8.tick();
          }
          setVideoData(chip8.getVideo());
          _this.state = getState();
          if (!$scope.$$phase) {
            $scope.$apply();
          }
          draw();
          rafId = requestAnimationFrame(mainLoop);
        };
      })(this);
      mainLoop();
    };
    this.stop = function() {
      this.running = false;
      cancelAnimationFrame(rafId);
    };
    this.reset = function() {
      var ex, program, text;
      this.stop();
      text = editor.getValue();
      if (text.length) {
        try {
          program = assembler.assemble(text);
          self.loadProgram(program);
        } catch (_error) {
          ex = _error;
        }
      }
      chip8.reset();
      this.state = getState();
      setVideoData(chip8.getVideo());
      return draw();
    };
    this.reset();
    this.loadProgram = chip8.load;
    this.step = function() {
      chip8.tick();
      this.state = getState();
      setVideoData(chip8.getVideo());
      draw();
    };
  });

}).call(this);
