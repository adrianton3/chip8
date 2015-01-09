'use strict'

Chip8Renderer = ->
  gl = null
  vertexPositionAttribute = null
  shaderProgram = null
  quadBuffer = null
  videoBuffer = new Uint8Array 64 * 32 * 4

  vertexShaderSource = """
    attribute vec3 position;

    varying highp vec2 texCoord;

    void main(void) {
      gl_Position = vec4(position, 1.0);
      texCoord = (position.xy + 1.0) / 2.0;
    }
  """

  fragmentShaderSource = """
    varying highp vec2 texCoord;

    uniform sampler2D uSampler;

    void main(void) {
      gl_FragColor = texture2D(uSampler, texCoord.st);
    }
  """


  initContext = (canvas) ->
    gl = canvas.getContext 'webgl'

    gl.clearColor 0, 0, 0, 1
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

    gl.viewport 0, 0, canvas.width, canvas.height

    initShaders()
    initTexture videoBuffer
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


  initTexture = (imageData) ->
    cubeTexture = gl.createTexture()
    gl.bindTexture gl.TEXTURE_2D, cubeTexture
    gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, 64, 32, 0, gl.RGBA, gl.UNSIGNED_BYTE, imageData

    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST
    gl.generateMipmap gl.TEXTURE_2D

    gl.activeTexture gl.TEXTURE0
    gl.uniform1i (gl.getUniformLocation shaderProgram, 'uSampler'), 0


  draw = ->
    gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
    gl.drawArrays gl.TRIANGLE_STRIP, 0, 4
    return


  setVideoData = (video) ->
    i4 = 0
    for i in [0...video.length]
      if video[i]
        videoBuffer[i4 + 0] = 255
        videoBuffer[i4 + 1] = 255
        videoBuffer[i4 + 2] = 255
      else
        videoBuffer[i4 + 0] = 0xC
        videoBuffer[i4 + 1] = 0xD
        videoBuffer[i4 + 2] = 0x8

      videoBuffer[i4 + 3] = 255

      i4 += 4

    gl.texSubImage2D gl.TEXTURE_2D, 0, 0, 0, 64, 32, gl.RGBA, gl.UNSIGNED_BYTE, videoBuffer
    return


  {
    initContext
    setVideoData
    draw
  }

window.Chip8Renderer = Chip8Renderer