!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

################################################################
# Modified by CnlPepper to implement a view incidence shader   #
# Modified by Supernova to implement surface and night shading #
# Modified by CnlPepper to add more control over atmosphere    #
################################################################

### NOTE: All shader operations calculated in EYE SPACE.

ATTRIB mapPos			= fragment.texcoord[0];		# texture coordinates
ATTRIB iNormal			= fragment.texcoord[4];		# interpolated eye space surface normal from vertex shader
ATTRIB iVertPos			= fragment.texcoord[5];		# interpolated eye space vertex position from vertex shader

PARAM lightDir			= state.light[0].position;	# main light position
PARAM lightHalf			= state.light[0].half;		# main light half vector
PARAM lightDiff			= state.lightprod[0].diffuse;	# main light diffuse colour product (multiplied by diffuse material property in .st file)
PARAM lightSpec			= state.lightprod[0].specular;	# main light specular colour product (multiplied by specular material property in .st file)
PARAM materialSpecExp		= state.material.shininess;	# material shininess defined in .st file
PARAM mv[4]		        = { state.matrix.modelview };	# modelview matrix

OUTPUT outColour		= result.color;

TEMP temp;
TEMP nlMask, nightLights;
TEMP texAtmos, texDiff, texGlow;
TEMP ePos, eRef, normal, gloss;
TEMP dotLN;
TEMP diffuse, specular, atmos;
TEMP final, fogColour;

### SAMPLE TEXTURES

TEX texDiff, mapPos, texture[0], 2D;
TEX texGlow, mapPos, texture[1], 2D;

### RE-NORMALISE SURFACE NORMAL (INTERPOLATION OF VERTEX VALUES WILL PRODUCE UNNORMALISED VECTORS)

DP3 normal, iNormal, iNormal; 
RSQ normal, normal.x;
MUL normal, iNormal, normal;

### CALCULATE EYE-SURFACE VECTOR

# assemble eye to object vector
MUL temp.x, mv[0].w, {0.001}.x;			# reduced magnitude to prevent possible overflow errors (fix for distant planets)
MUL temp.y, mv[1].w, {0.001}.x;			# reduced magnitude to prevent possible overflow errors (fix for distant planets)
MUL temp.z, mv[2].w, {0.001}.x;			# reduced magnitude to prevent possible overflow errors (fix for distant planets)

# add object to surface vector (interpolated from vertex positions)
MAD temp, iVertPos, {0.001}.x, temp;		# reduced magnitude to prevent possible overflow errors (fix for distant planets)

# normalise
DP3 ePos, temp, temp; 
RSQ ePos, ePos.x;
MUL ePos, temp, ePos;

### CALCULATE TEXTURE COORDINATE FROM ANGLE OF INCIDENCE

DP3 temp, ePos, normal;
ABS texAtmos.x, temp;
MOV texAtmos.y, {0.5}.x;			# reads along vertical center of texture (ie y = 0.5)
MAD texAtmos, texAtmos, {0.90}.x, {0.05}.x;	# avoid edges of texture due to texture wrapping

### SAMPLE ATMOSPHERE TEXTURE

TEX atmos, texAtmos, texture[2], 2D;

### CALCULATE SURFACE DIFFUSE LIGHTING CONTRIBUTION (PER-PIXEL)

DP3 dotLN, lightDir, normal;			# cache for later use in Phong specular stage
MUL diffuse, dotLN, lightDiff;

### SETUP NIGHTLIGHT MASK (DISABLED AS NOT GENERAL)

#SUB nightLights, {0.25}.x, diffuse; 
#MAX nightLights, {0}.x, nightLights; #PREVENTS NEGATIVE VALUES;

### CALCULATE SURFACE SPECULAR LIGHTING CONTRIBUTION (PER-PIXEL, BLINN-PHONG MODEL)

#DP3 temp.x, lightHalf, normal;
#MAX temp.x, misc.x, temp.x;			# prevent negative values
#POW specular, temp.x, materialSpecExp.x;
#MUL specular, specular, texGlow.b;
#MUL specular, specular, lightSpec;

### CALCULATE SURFACE SPECULAR LIGHTING CONTRIBUTION (PER-PIXEL, FULL PHONG MODEL)

# calculate glossiness from texture value
POW temp, texGlow.r, {3}.x;
MAD gloss, temp, program.local[4], program.local[5];

# calculate reflection vector
MUL temp, normal, dotLN.x;
MUL temp, temp, {2}.x;
SUB eRef, lightDir, temp;

# calculate specular
DP3 temp.x, eRef, ePos;
MAX temp.x, {0}.x, temp.x;			# prevent negative values
POW specular, temp.x, gloss.x;
MUL specular, specular, texGlow.b;
MUL specular, specular, lightSpec;

### COMBINE LIGHTING AND SHADING

# planet surface
#MAD diffuse, nightLights, texGlow.g, diffuse;	# disabled as not general
MAD temp, texDiff, diffuse, texGlow.g;
ADD temp, temp, specular;

# atmosphere
MUL atmos.rgb, atmos, diffuse;
LRP final, atmos.a, atmos, temp;

### APPLY FOG

MOV fogColour, program.local[3];
MUL fogColour.a, fogColour, diffuse;
LRP outColour, fogColour.a, fogColour, final;
MOV outColour.a, {1}.x;				# fix alpha

END
