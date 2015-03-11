// Generated by CoffeeScript 1.8.0
(function() {
  'use strict';
  var Chip8Disassembler;

  Chip8Disassembler = function() {
    var decodeInstruction, disassemble, i, instructionPatterns, registerNames, serialize, serializeInstruction, setupInstructions, uniqueSorted;
    setupInstructions = function() {
      var add, add_NNN, add_XNN, add_XY_, add_X__, decode_NNN, decode_XNN, decode_XY_, decode_X__, ret;
      ret = new Map;
      decode_NNN = function(type) {
        return function(instruction) {
          return {
            type: type,
            NNN: instruction & 0x0FFF
          };
        };
      };
      decode_XNN = function(type) {
        return function(instruction) {
          return {
            type: type,
            X: (instruction & 0x0F00) >> 8,
            NN: instruction & 0x00FF
          };
        };
      };
      decode_XY_ = function(type) {
        return function(instruction) {
          return {
            type: type,
            X: (instruction & 0x0F00) >> 8,
            Y: (instruction & 0x00F0) >> 4
          };
        };
      };
      decode_X__ = function(type) {
        return function(instruction) {
          return {
            type: type,
            X: (instruction & 0x0F00) >> 8
          };
        };
      };
      add = Map.prototype.set.bind(ret);
      add_NNN = function(pattern, name) {
        return add(pattern, decode_NNN(name));
      };
      add_XNN = function(pattern, name) {
        return add(pattern, decode_XNN(name));
      };
      add_XY_ = function(pattern, name) {
        return add(pattern, decode_XY_(name));
      };
      add_X__ = function(pattern, name) {
        return add(pattern, decode_X__(name));
      };
      add(0x00E0, function() {
        return {
          type: 'cls'
        };
      });
      add(0x00EE, function() {
        return {
          type: 'return'
        };
      });
      add_NNN(0x1000, 'jump');
      add_NNN(0x2000, 'call');
      add_XNN(0x3000, 'sei');
      add_XNN(0x4000, 'snei');
      add_XY_(0x5000, 'ser');
      add_XNN(0x6000, 'movi');
      add_XNN(0x7000, 'addi');
      add_XY_(0x8000, 'movr');
      add_XY_(0x8001, 'and');
      add_XY_(0x8002, 'xor');
      add_XY_(0x8003, 'addr');
      add_XY_(0x8004, 'subr');
      add_XY_(0x8005, 'shr');
      add_XY_(0x8006, 'nsubr');
      add_XY_(0x8007, 'shl');
      add_XY_(0x800E, 'sner');
      add_XY_(0x9000, 'or');
      add_NNN(0xA000, 'imovi');
      add_NNN(0xB000, 'jumpoff');
      add_XNN(0xC000, 'rnd');
      add(0xD000, function(instruction) {
        return {
          type: 'sprite',
          X: (instruction & 0x0F00) >> 8,
          Y: (instruction & 0x00F0) >> 4,
          N: instruction & 0x000F
        };
      });
      add_X__(0xE09E, 'skr');
      add_X__(0xE0A1, 'snkr');
      add_X__(0xF007, 'rmovt');
      add_X__(0xF00A, 'waitk');
      add_X__(0xF015, 'movt');
      add_X__(0xF018, 'movs');
      add_X__(0xF01E, 'iaddr');
      add_X__(0xF029, 'digit');
      add_X__(0xF033, 'bcd');
      add_X__(0xF055, 'store');
      add_X__(0xF065, 'load');
      return ret;
    };
    instructionPatterns = setupInstructions();
    registerNames = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; _i <= 15; i = ++_i) {
        _results.push("v" + ((i.toString(16)).toUpperCase()));
      }
      return _results;
    })();
    serializeInstruction = function(instruction, labels) {
      var N, NN, NNN, X, Y, type, word;
      type = instruction.type, X = instruction.X, Y = instruction.Y, N = instruction.N, NN = instruction.NN, NNN = instruction.NNN, word = instruction.word;
      if (NNN != null) {
        return "" + type + " " + (labels.get(NNN));
      } else if (NN != null) {
        return "" + type + " " + registerNames[X] + " " + NN;
      } else if (N != null) {
        return "" + type + " " + registerNames[X] + " " + registerNames[Y] + " " + N;
      } else if (Y != null) {
        return "" + type + " " + registerNames[X] + " " + registerNames[Y];
      } else if (X != null) {
        return "" + type + " " + registerNames[X];
      } else if (type === 'dw') {
        return "dw 0x" + ((word.toString(16)).toUpperCase()) + " ; " + word + " ; 0b" + (word.toString(2));
      } else {
        return type;
      }
    };
    decodeInstruction = function(high, low) {
      var decoder, instruction, mask, masked, _i, _len, _ref;
      instruction = (high << 8) | low;
      _ref = [0xF000, 0xF00F, 0xF0FF];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mask = _ref[_i];
        masked = instruction & mask;
        if (instructionPatterns.has(masked)) {
          decoder = instructionPatterns.get(masked);
          return decoder(instruction);
        }
      }
      return {
        type: 'dw',
        word: instruction
      };
    };
    serialize = function(instructions, jumpAddresses) {
      var instruction, labels, lines, pointer, programCounter, _i, _len;
      labels = jumpAddresses.reduce(function(map, address, index) {
        return map.set(address, "label-" + (index + 1));
      }, new Map);
      pointer = 0;
      programCounter = 0;
      lines = [];
      for (_i = 0, _len = instructions.length; _i < _len; _i++) {
        instruction = instructions[_i];
        while (jumpAddresses[pointer] <= programCounter) {
          pointer++;
          lines.push("label-" + pointer + ":");
        }
        lines.push(serializeInstruction(instruction, labels));
        programCounter += 2;
      }
      return lines.join('\n');
    };
    uniqueSorted = function(array) {
      var ret, _i, _ref;
      ret = [];
      for (i = _i = 1, _ref = array.length; 1 <= _ref ? _i < _ref : _i > _ref; i = 1 <= _ref ? ++_i : --_i) {
        if (array[i - 1] !== array[i]) {
          ret.push(array[i - 1]);
        }
      }
      ret.push(array[i - 1]);
      return ret;
    };
    disassemble = function(program, startOffset) {
      var decodedInstruction, decodedInstructions, instructionHi, instructionLo, jumpAddresses, programCounter, _i;
      if (startOffset == null) {
        startOffset = 0x0200;
      }
      decodedInstructions = [];
      jumpAddresses = [];
      for (programCounter = _i = 0x000; _i <= 0xFFF; programCounter = _i += 2) {
        instructionHi = program[programCounter];
        instructionLo = program[programCounter + 1];
        if (!(instructionHi | instructionLo)) {
          break;
        }
        decodedInstruction = decodeInstruction(instructionHi, instructionLo);
        decodedInstructions.push(decodedInstruction);
        if (decodedInstruction.NNN != null) {
          decodedInstruction.NNN -= startOffset;
          decodedInstruction.NNN = Math.max(0, decodedInstruction.NNN);
          jumpAddresses.push(decodedInstruction.NNN);
        }
      }
      jumpAddresses.sort();
      jumpAddresses = uniqueSorted(jumpAddresses);
      return {
        instructions: decodedInstructions,
        jumpAddresses: jumpAddresses
      };
    };
    return {
      decodeInstruction: decodeInstruction,
      disassemble: disassemble,
      serialize: serialize
    };
  };

  window.Chip8Disassembler = Chip8Disassembler;

}).call(this);
