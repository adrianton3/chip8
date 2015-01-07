'use strict'

Chip8Renderer = ->

  gl = null
  vertexPositionAttribute = null
  quadBuffer = null

  vertexShaderSource = """
    attribute vec3 position;

    void main(void) {
      gl_Position = vec4(position, 1.0);
    }
  """

  fragmentShaderSource = """
    void main(void) {
      gl_FragColor = vec4(1.0, 0.2, 0.5, 1.0);
    }
  """


  initContext = (canvas) ->
    gl = canvas.getContext 'webgl'

    gl.clearColor 0, 0, 0, 1
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

    gl.viewport 0, 0, canvas.width, canvas.height

    initShaders()
    initQuad()
    return


  getShader = (type, source) ->
    shader = gl.createShader type
    gl.shaderSource shader, source
    gl.compileShader shader
    shader


  initShaders = ->
    vertexShader = getShader gl.VERTEX_SHADER, vertexShaderSource
    fragmentShader = getShader gl.FRAGMENT_SHADER, fragmentShaderSource

    shaderProgram = gl.createProgram()
    gl.attachShader shaderProgram, vertexShader
    gl.attachShader shaderProgram, fragmentShader
    gl.linkProgram shaderProgram

    gl.useProgram shaderProgram

    vertexPositionAttribute = gl.getAttribLocation shaderProgram, 'position'
    gl.enableVertexAttribArray vertexPositionAttribute
    return


  initQuad = ->
    quadBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, quadBuffer
    vertices = new Float32Array [
       1,  1, 0
      -1,  1, 0
       1, -1, 0
      -1, -1, 0
    ]
    gl.bufferData gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW
    gl.vertexAttribPointer vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0
    return


  draw = ->
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
    gl.drawArrays gl.TRIANGLE_STRIP, 0, 4
    return


  {
    initContext
    draw
  }

window.Chip8Renderer = Chip8Renderer