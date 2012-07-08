!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

#########################################################
# Modified by CnlPepper to implement per-pixel lighting #
#########################################################

### NOTE: All shader operations calculated in EYE SPACE.

ATTRIB texPos		= fragment.texcoord[0];			# texture coordinates
ATTRIB iNormal		= fragment.texcoord[4];			# interpolated eye space surface normal from vertex shader
ATTRIB iVertPos		= fragment.texcoord[5];			# interpolated eye space vertex position from vertex shader

PARAM lightDir		= state.light[0].position;		# main light position
PARAM lightHalf		= state.light[0].half;			# main light half vector
PARAM lightDiff		= state.lightprod[0].diffuse;		# main light diffuse colour product (multiplied by diffuse material property in .st file)
PARAM lightSpec		= state.lightprod[0].specular;		# main light specular colour product (multiplied by specular material property in .st file)
PARAM materialSpecExp	= state.material.shininess;		# material shininess defined in .st file
PARAM mv[4]		= { state.matrix.modelview };		# modelview matrix
PARAM misc		= { 0, 0.5, 1.0, 2.0 };

OUTPUT outColour	= result.color;

TEMP temp;
TEMP weight, texDiffOn, texDiffOff, texDiff, texGlow;
TEMP ePos, eRef, normal, gloss;
TEMP dotLN;
TEMP diffuse, specular;
TEMP colBase, colStripe, nBase, nStripe, colour;

### SAMPLE TEXTURES

TEX texDiffOn, texPos, texture[1], 2D;
TEX texDiffOff, texPos, texture[2], 2D;
TEX texGlow, texPos, texture[3], 2D;

### WEIGHTED AVERAGE THE DIFFUSE AND GLOW TEXTURES

MOV weight, program.local[0];
LRP texDiff, weight, texDiffOn, texDiffOff;

### RE-NORMALISE SURFACE NORMAL (INTERPOLATION OF VERTEX VALUES WILL PRODUCE UNNORMALISED VECTORS)

DP3 normal, iNormal, iNormal; 
RSQ normal, normal.x;
MUL normal, iNormal, normal;

### CALCULATE DIFFUSE LIGHTING CONTRIBUTION (PER-PIXEL)

DP3 dotLN.x, lightDir, normal;
MUL diffuse, dotLN.x, lightDiff;

### CALCULATE SPECULAR LIGHTING CONTRIBUTION (PER-PIXEL, BLINN-PHONG MODEL)

#DP3 temp.x, lightHalf, normal;
#MAX temp.x, misc.x, temp.x;		# prevent negative values
#POW specular, temp.x, materialSpecExp.x;
#MUL specular, specular, texGlow.b;
#MUL specular, specular, lightSpec;

### CALCULATE SPECULAR LIGHTING CONTRIBUTION (PER-PIXEL, FULL PHONG MODEL)

# assemble eye to object vector
MOV temp.x, mv[0].w;
MOV temp.y, mv[1].w;
MOV temp.z, mv[2].w;

# add object to surface vector (interpolated from vertex positions)
ADD temp, iVertPos, temp;

# normalise
DP3 ePos, temp, temp; 
RSQ ePos, ePos.x;
MUL ePos, temp, ePos;

# calculate glossiness from texture value
POW temp, texGlow.r, {3}.x;
MAD gloss, temp, program.local[4], program.local[5];

# calculate reflection vector
MUL temp, normal, dotLN.x;
MUL temp, temp, {2}.x;
SUB eRef, lightDir, temp;

# calculate specular
DP3 temp.x, eRef, ePos;
MAX temp.x, misc.x, temp.x;		# prevent negative values
POW specular, temp.x, gloss.x;
MUL specular, specular, texGlow.b;
MUL specular, specular, lightSpec;

### GENERATE PRE-SHADING SURFACE COLOUR FROM BASE AND TEAM STRIPE COLOURS

# make darker
ADD temp, texDiff, misc.y;
MUL colBase, temp, program.local[1];
MUL colStripe, temp, program.local[2];

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

### TESTING

#MOV outColour, texDiffOff;
#ADD outColour, diffLight, specLight;

END
