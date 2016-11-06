// Generated by CoffeeScript 1.11.0
(function() {
  'use strict';
  var Range, app;

  Range = (ace.require('ace/range')).Range;

  app = angular.module('Assembler', []);

  app.controller('AssemblerController', [
    '$scope', '$http', function($scope, $http) {
      var TICKS_PER_FRAME, assembler, breakpoints, chip8, clearBreakPoints, clearMarker, draw, editor, errorLine, getEmulatorState, initContext, keyboard, lineMapping, loadSample, makeReverseMapping, marker, onChange, pausedAt, rafId, ref, reverseMapping, setVideoData, setupEditor;
      ref = Chip8Renderer(), initContext = ref.initContext, draw = ref.draw, setVideoData = ref.setVideoData;
      initContext(document.getElementById('can'));
      TICKS_PER_FRAME = 1;
      rafId = null;
      editor = null;
      errorLine = null;
      lineMapping = null;
      reverseMapping = null;
      marker = null;
      breakpoints = new Set;
      pausedAt = null;
      this.status = 'idle';
      this.emulatorState = null;
      this.liveAutocomplete = (localStorage.getItem('live-autocompletion')) === 'true';
      assembler = Chip8Assembler();
      keyboard = Chip8Keyboard();
      (document.getElementById('container')).appendChild(keyboard.getHtml());
      chip8 = Chip8();
      chip8.setKeyboard(keyboard);
      onChange = function(text) {
        var ex;
        clearMarker();
        clearBreakPoints();
        if (text.length === 0) {
          editor.getSession().setAnnotations([]);
        } else {
          try {
            assembler.assemble(text);
            if (errorLine !== null) {
              editor.getSession().setAnnotations([]);
              errorLine = null;
            }
          } catch (error) {
            ex = error;
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
        editor.setOptions({
          enableBasicAutocompletion: true,
          enableLiveAutocompletion: (localStorage.getItem('live-autocompletion')) === 'true'
        });
        editor.$blockScrolling = 2e308;
        editor.getSession().setMode('ace/mode/chip8');
        editor.setTheme('ace/theme/monokai');
        editor.on('input', function() {
          return onChange(editor.getValue());
        });
        editor.on('guttermousedown', function(event) {
          var row;
          if (!event.domEvent.target.classList.contains('ace_gutter-cell')) {
            return;
          }
          row = event.getDocumentPosition().row;
          if (reverseMapping == null) {
            lineMapping = assembler.assemble(editor.getValue()).lineMapping;
            reverseMapping = makeReverseMapping(lineMapping);
          }
          if (reverseMapping.has(row)) {
            if (breakpoints.has(row)) {
              breakpoints["delete"](row);
              editor.session.clearBreakpoint(row);
            } else {
              breakpoints.add(row);
              editor.session.setBreakpoint(row);
            }
          }
          event.stop();
        });
      };
      setupEditor();
      clearBreakPoints = function() {
        breakpoints.forEach(function(row) {
          editor.session.clearBreakpoint(row);
        });
        breakpoints.clear();
      };
      getEmulatorState = function() {
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
      loadSample = function(sampleName) {
        return $http.get("samples/" + sampleName + ".chip8", {
          responseType: 'text'
        }).success((function(_this) {
          return function(source) {
            return editor.setValue(source, -1);
          };
        })(this));
      };
      loadSample('sprites');
      clearMarker = function() {
        if (marker != null) {
          editor.getSession().removeMarker(marker);
        }
        marker = null;
      };
      makeReverseMapping = function(mapping) {
        var reverse;
        reverse = new Map;
        mapping.forEach(function(value, key) {
          reverse.set(value, key);
        });
        return reverse;
      };
      this.clearMarker = clearMarker;
      this.updateMarker = function() {
        var line, range;
        this.clearMarker();
        if (lineMapping != null) {
          line = lineMapping.get(this.emulatorState.programCounter);
          if (line != null) {
            range = new Range(line, 0, line, 100);
            marker = editor.getSession().addMarker(range, 'active-line', 'fullLine');
          }
        }
      };
      this.updateVideo = function() {
        setVideoData(chip8.getVideo());
        return draw();
      };
      this.updateEmulatorState = function() {
        return this.emulatorState = getEmulatorState();
      };
      this.startMainLoop = function() {
        var mainLoop;
        if (this.status === 'running') {
          return;
        }
        this.status = 'running';
        mainLoop = (function(_this) {
          return function() {
            var i, j, programCounter, ref1;
            for (i = j = 0, ref1 = TICKS_PER_FRAME; 0 <= ref1 ? j < ref1 : j > ref1; i = 0 <= ref1 ? ++j : --j) {
              programCounter = chip8.getProgramCounter();
              if ((breakpoints.has(lineMapping.get(programCounter))) && pausedAt !== programCounter) {
                pausedAt = programCounter;
                _this.status = 'paused';
                _this.updateEmulatorState();
                _this.updateMarker();
                if (!$scope.$$phase) {
                  $scope.$apply();
                }
                _this.updateVideo();
                return;
              }
              chip8.tick();
            }
            _this.updateEmulatorState();
            if (!$scope.$$phase) {
              $scope.$apply();
            }
            _this.updateVideo();
            rafId = requestAnimationFrame(mainLoop);
          };
        })(this);
        mainLoop();
      };
      this.stopMainLoop = function() {
        cancelAnimationFrame(rafId);
        rafId = null;
      };
      this.start = function() {
        if (this.status === 'idle') {
          this.reset();
        }
        this.clearMarker();
        this.startMainLoop();
      };
      this.pause = function() {
        this.status = 'paused';
        this.stopMainLoop();
        this.updateMarker();
      };
      this.stop = function() {
        this.status = 'idle';
        pausedAt = null;
        this.stopMainLoop();
      };
      this.reset = function() {
        var ex, instructions, ref1, text;
        this.stop();
        text = editor.getValue();
        if (text.length) {
          try {
            ref1 = assembler.assemble(text), instructions = ref1.instructions, lineMapping = ref1.lineMapping;
            reverseMapping = makeReverseMapping(lineMapping);
            chip8.load(instructions);
          } catch (error) {
            ex = error;
          }
        }
        chip8.reset();
        this.updateEmulatorState();
        this.updateVideo();
        this.updateMarker();
      };
      this.reset();
      this.step = function() {
        if (this.status === 'idle') {
          this.reset();
        }
        this.status = 'paused';
        pausedAt = null;
        chip8.tick();
        this.updateEmulatorState();
        this.updateVideo();
        this.updateMarker();
      };
      this.toggleLiveAutocomplete = function() {
        localStorage.setItem('live-autocompletion', this.liveAutocomplete);
        return editor.setOption('enableLiveAutocompletion', this.liveAutocomplete);
      };
    }
  ]);

}).call(this);