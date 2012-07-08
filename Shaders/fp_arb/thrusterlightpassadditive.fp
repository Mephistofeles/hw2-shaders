!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

#######################################################
# Modified by CnlPepper to support per-pixel lighting #
#######################################################

ATTRIB texPos		= fragment.texcoord[0];		# texture coordinates
ATTRIB iDiff		= fragment.color.primary;	# interpolated vertex diffuse color
ATTRIB iSpec		= fragment.color.secondary;	# interpolated vertex specular color
PARAM misc		= { 0, 0.5, 1.0, 2.0 };

OUTPUT outColour 	= result.color;

TEMP temp;
TEMP weight, texDiffOn, texGlowOn, texDiffOff, texGlowOff, texDiff, texGlow;
TEMP diffuse, specular;
TEMP colBase, colStripe, nBase, nStripe, colour;

### SAMPLE TEXTURES

TEX texDiffOn, texPos, texture[0], 2D;
TEX texDiffOff, texPos, texture[1], 2D;
TEX texGlowOn, texPos, texture[2], 2D;
TEX texGlowOff, texPos, texture[3], 2D;

### WEIGHTED AVERAGE THE DIFFUSE AND GLOW TEXTURES

MOV weight, program.local[0];
LRP texDiff, weight, texDiffOn, texDiffOff;
LRP texGlow, weight, texGlowOn, texGlowOff;

### CALCULATE GLOW AND DIFFUSE CONTRIBUTIONS (TEXTURE/VERTEX)

MUL temp, texGlow.g, program.local[1];		# scale intensity by external glow colour multiplier
ADD diffuse, iDiff, temp;

### CALCULATE SPECULAR LIGHTING CONTRIBUTION (VERTEX)

MUL specular, iSpec, texGlow.b;

### GENERATE PRE-SHADING SURFACE COLOUR FROM BASE AND TEAM STRIPE COLOURS

# make darker
ADD temp, texDiff, misc.y;
MUL colBase, temp, program.local[2];
MUL colStripe, temp, program.local[3];

# make lighter
SUB temp, texDiff, misc.y;
ADD colBase, temp, colBase;
ADD colStripe, temp, colStripe;

# compute amount of team colour needed
SUB nBase, misc.z, texDiff.a;
SUB nStripe, misc.z, texGlow.a;

# average the team colour and base texture
LRP temp.rgb, nBase, colBase, texDiff;
LRP colour, nStripe, colStripe, temp;

### COMBINE LIGHTING AND SHADING

MUL temp, colour, diffuse;
ADD outColour, temp, specular;

END
