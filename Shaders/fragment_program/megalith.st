static Texture $diffuse
static Texture $glow

simple base(Texture $diffuse, Texture $glow, Texture $atmo, Colour $teambase, Colour $teamstripe, Colour $fogColour, Colour $addColour, Colour $shadowColour)
{
    setCap depthBufferCap true
    setCap gouraudCap true
    setCap cullCap true
    setCap texture1Cap true
    setCap texture2Cap true
    setCap lightingCap true
    setCap blendCap true
    setCap vertexProgramCap true
    setCap fragmentProgramCap	true
    
    setCap texgenSCap true
    setCap texgenTCap true
    setCap texgenRCap true
    setCap texgenQCap true    
    
    setVertexProgram asteroidVertexProgram0

    srcBlend	oneBlend
    destBlend	zeroBlend

    fillMode solidFill
    cullMode backCull

    material ambient   1 1 1 1
    material diffuse   1 1 1 1
    material specular  1 1 1 1
    material shininess 75 75 75 75
    setVertexColour    1 1 1 1

    textureBind 0 $diffuse
    textureBind 1 $glow
    textureBind 2 $atmo

    setFragmentProgram megalithFragmentProgram

    setProgramVarLocal fragmentProgram 0x0 $teambase
    setProgramVarLocal fragmentProgram 0x1 $teamstripe
    setProgramVarLocal fragmentProgram 0x3 $fogColour
    setProgramVarLocal fragmentProgram 0x4  240  240  240 1	// glossiness scale
    setProgramVarLocal fragmentProgram 0x5   10   10   10 1	// glossiness bias (added)    
}


compound megalith()
{
    addPass base
}
