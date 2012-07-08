!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

###############################################################################
# Modified by CnlPepper to implement per-pixel lighting with parallax mapping #
###############################################################################

### NOTE: All shader operations calculated in TANGENT SPACE.

ATTRIB texPos		= fragment.texcoord[0];			# texture coordinates
ATTRIB lightDir		= fragment.texcoord[2];			# texture coordinates
ATTRIB eyeVec		= fragment.texcoord[3];			# texture coordinates

PARAM lightDiff		= state.lightprod[0].diffuse;		# main light diffuse colour product (multiplied by diffuse material property in .st file)
PARAM lightSpec		= state.lightprod[0].specular;		# main light specular colour product (multiplied by specular material property in .st file)
PARAM materialSpecExp	= state.material.shininess;		# material shininess defined in .st file
PARAM misc		= { 0, 0.5, 1.0, 2.0 };

OUTPUT outColour	= result.color;

TEMP temp;
TEMP newPos;
TEMP texDiff, texGlow, texNorm;
TEMP eye, reflection, normal, height, light, gloss;
TEMP dotLN;
TEMP diffuse, specular;
TEMP colBase, colStripe, wBase, wStripe, colour;

### RE-NORMALISE EYE VECTOR

DP3 eye, eyeVec, eyeVec; 
RSQ eye, eye.x;
MUL eye, eyeVec, eye;

### RE-NORMALISE LIGHT VECTOR

DP3 light, lightDir, lightDir; 
RSQ light, light.x;
MUL light, lightDir, light;

### GET NORMAL AND HEIGHT FROM TEXTURE AND UNPACK NORMAL

TEX texNorm, texPos, texture[3], 2D;
MOV height, texNorm.a;
MAD temp, texNorm, 2, -1;

### RE-NORMALISE NORMAL

DP3 normal, temp, temp; 
RSQ normal, normal.x;
MUL normal, temp, normal;

### CALCULATE NEW TEXTURE COORDINATE AND GET SHIFTED TEXTURES (PARALLAX MAPPING)

# shift texture coordinate (offset limited parallax mapping)
#MUL height, height, program.local[2];		# scale defined in shader pass
#SUB height, height, program.local[3];		# bias defined in shader pass
#MAD newPos, height, eye, texPos;

# shift texture coordinate (offset limited parallax mapping with slope information)
MUL height, height, program.local[2];		# scale defined in shader pass
SUB height, height, program.local[3];		# bias defined in shader pass
MUL temp, height, normal.z;
MAD newPos, temp, eye, texPos;

# sample textures
TEX texGlow, newPos, texture[1], 2D;
TEX texDiff, newPos, texture[2], 2D;
TEX texNorm, newPos, texture[3], 2D;

### UNPACK AND RE-NORMALISE NEW NORMAL

MAD temp, texNorm, 2, -1;
DP3 normal, temp, temp; 
RSQ normal, normal.x;
MUL normal, temp, normal;

### CALCULATE DIFFUSE LIGHTING

DP3 dotLN, light, normal;
MUL_SAT diffuse, dotLN, lightDiff;		# prevent negative values

### CALCULATE SURFACE SPECULAR LIGHTING CONTRIBUTION (FULL PHONG MODEL)

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# calculate glossiness from texture value
POW temp, texGlow.r, {3}.x;
MAD gloss, temp, program.local[4], program.local[5];

# calculate specular
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MUL specular, temp, lightSpec;

### GENERATE PRE-SHADING SURFACE COLOUR FROM BASE AND TEAM STRIPE COLOURS

# make darker
ADD temp, texDiff, misc.y;
MUL colBase, temp, program.local[0];
MUL colStripe, temp, program.local[1];

# make lighter
SUB temp, texDiff, misc.y;
ADD colBase, temp, colBase;
ADD colStripe, temp, colStripe;

# compute amount of team colour needed
SUB wBase, misc.z, texDiff.a;
SUB wStripe, misc.z, texGlow.a;

# average the team colour and base texture
LRP temp.rgb, wBase, colBase, texDiff;
LRP colour, wStripe, colStripe, temp;

### COMBINE LIGHTING AND SHADING

MAD outColour, colour, diffuse, specular;



### TESTING

#MOV outColour, specular;

#ADD outColour, diffuse, specular;

#MUL outColour, texNorm.a, {0.5}.x;

#MUL outColour, eye, specular;

#ATTRIB iTangent		= fragment.texcoord[6];			
#DP3 temp, iTangent, iTangent; 
#RSQ temp, temp.x;
#MUL temp, iTangent, temp;
#ABS temp, temp;
#MOV outColour, temp;

#TEMP temp2;
#ATTRIB iNormal		= fragment.texcoord[7];			
#DP3 temp2, iNormal, iNormal; 
#RSQ temp2, temp2.x;
#MUL temp2, iNormal, temp2;
#ABS temp2, temp2;
#MOV outColour, temp2;

#DP3 temp, temp, temp2;
#MOV temp, fragment.texcoord[7];			
#MUL temp.y, temp.y, {-1}.x;
#MOV temp.z, {0}.x;
#MUL outColour, temp, {1}.x;



#MUL outColour, iTangent, {0.5}.x;
#DP3 outColour, iTangent, iNormal;

#MUL temp, iTangent, {-1}.x;
#ABS temp, iTangent;
#LRP temp, {0.8}.x, temp, texDiff;
#MUL outColour, temp, {0.5}.x;

END
