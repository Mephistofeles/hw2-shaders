// Modified by CnlPepper to support per-pixel normal mapped lighting

simple light(Texture $diffuse, Texture $glow, Texture $normal, Colour $teambase, Colour $teamstripe, Colour $fogColour, Colour $addColour, Colour $shadowColour)
{
    setCap depthBufferCap true
    setCap gouraudCap true
    setCap cullCap true
    setCap texture0Cap true    
    setCap texture1Cap true
    setCap texture2Cap true
    setCap lightingCap true
    setCap separateSpecularCap	true    
    setCap blendCap true
    setCap vertexProgramCap true
    setCap fragmentProgramCap	true

    setVertexProgram asteroidVertexProgram1

    srcBlend oneBlend
    destBlend oneBlend

    fillMode solidFill
    cullMode backCull

    material ambient   1 1 1 1
    material diffuse   1 1 1 1
    material specular  1 1 1 1
    material shininess 96 96 96 96
    setVertexColour    1 1 1 1

    textureBind 0 $diffuse
    textureBind 1 $glow
    textureBind 2 $normal

    setFragmentProgram thrusterGlowPassFragmentProgram

    setProgramVarLocal fragmentProgram 0x0 0.5 0.5 0.5 0.5	// glow colour multiplier
    setProgramVarLocal fragmentProgram 0x1 $teambase
    setProgramVarLocal fragmentProgram 0x2 $teamstripe
    setProgramVarLocal fragmentProgram 0x3 0.02 0.02 0.02 1.0	// parallax bias
    setProgramVarLocal fragmentProgram 0x4 0.01 0.01 0.01 1.0	// parallax scale
    setProgramVarLocal fragmentProgram 0x5  240  240  240 1	// glossiness scale
    setProgramVarLocal fragmentProgram 0x6   10   10   10 1	// glossiness bias (added)
    
}

simple fog(Texture $diffuse, Texture $glow, Texture $normal, Colour $teambase, Colour $teamstripe, Colour $fogColour, Colour $addColour, Colour $shadowColour)
{
    setCap depthBufferCap   true
    setCap gouraudCap       true
    setCap blendCap         true
    setCap cullCap          true
    setCap texture0Cap      true

    srcBlend srcAlphaBlend
    destBlend invSrcAlphaBlend

    fillMode solidFill
    cullMode backCull

	//----------------stage 0----------
    activeTexture 0
    textureBind 0 $glow
    combineColourStage 0 $fogColour
    textureMode	combineMode
    combineSource	rgb	arg0	constantSrc	srcColour
    combineFunction	rgb	replaceCombine		1
    combineSource	alpha	arg0	primarySrc	srcAlpha
    combineSource	alpha	arg1	constantSrc	srcAlpha
    combineFunction	alpha	modulateCombine		1
}

simple additive(Texture $diffuse, Texture $glow, Texture $normal, Colour $teambase, Colour $teamstripe, Colour $fogColour, Colour $addColour, Colour $shadowColour)
{
    setCap depthBufferCap 	true
    setCap gouraudCap 		true
    setCap blendCap 		true
    setCap cullCap		true

    srcBlend srcAlphaBlend
    destBlend oneBlend

    fillMode solidFill
    cullMode backCull

    material ambient   1 1 1 1
    material diffuse   1 1 1 1
    material specular  1 1 1 1
    material shininess 96 96 96 96
    setVertexColour    $addColour

    setFragmentProgram additiveFragmentProgram

    setProgramVarLocal fragmentProgram 0x0 $addColour
}

compound matteAdditiveLight()
{
    addPass light
    addPass fog
    addPass additive 0
}
