// Modified by CnlPepper to support per-pixel lighting

static Texture $diffuseOn
static Texture $glowOn
static Texture $diffuseOff
static Texture $glowOff

simple light(Texture $diffuse0, Texture $glow0, Texture $diffuseOn, Texture $glowOn, Texture $diffuseOff, Texture $glowOff, Colour $teambase, Colour $teamstripe, Colour $weight, Colour $fogColour, Colour $addColour, Colour $shadowColour)
{
    setCap depthBufferCap	true
    setCap gouraudCap		true
    setCap cullCap		true
    setCap texture0Cap		true
    setCap texture1Cap		true
    setCap texture2Cap		true
    setCap texture3Cap		true    
    setCap lightingCap		true
    setCap fragmentProgramCap	true
    setCap separateSpecularCap	true
    setCap blendCap 		true

    srcBlend oneBlend
    destBlend oneBlend

    fillMode solidFill
    cullMode backCull

    material ambient   1 1 1 1
    material diffuse   1 1 1 1
    material specular  1 1 1 1
    material shininess 96 96 96 96
    setVertexColour    1 1 1 1

    textureBind 0 $diffuseOn
    textureBind 1 $diffuseOff
    textureBind 2 $glowOn
    textureBind 3 $glowOff

    setFragmentProgram thrusterLightPassAdditiveFragmentProgram

    setProgramVarLocal fragmentProgram 0x0 $weight
    setProgramVarLocal fragmentProgram 0x1 0.5 0.5 0.5 0.5	// glow colour multiplier
    setProgramVarLocal fragmentProgram 0x2 $teambase
    setProgramVarLocal fragmentProgram 0x3 $teamstripe
}

simple fog(Texture $diffuse0, Texture $glow0, Texture $diffuseOn, Texture $glowOn, Texture $diffuseOff, Texture $glowOff, Colour $teambase, Colour $teamstripe, Colour $weight, Colour $fogColour, Colour $addColour, Colour $shadowColour)

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
    combineSource	rgb		arg0	constantSrc	srcColour
    combineFunction	rgb		replaceCombine		1
    combineSource	alpha	arg0	primarySrc	srcAlpha
    combineSource	alpha	arg1	constantSrc	srcAlpha
    combineFunction	alpha	modulateCombine		1
}

simple additive(Texture $diffuse0, Texture $glow0, Texture $diffuseOn, Texture $glowOn, Texture $diffuseOff, Texture $glowOff, Colour $teambase, Colour $teamstripe, Colour $weight, Colour $fogColour, Colour $addColour, Colour $shadowColour)

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

compound thrusterAdditiveLight()
{
    addPass light
    addPass fog
    addPass additive 0
}
