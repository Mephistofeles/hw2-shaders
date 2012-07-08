!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

###############################################################################
# Modified by CnlPepper to implement per-pixel lighting with parallax mapping #
###############################################################################

### NOTE: All shader operations calculated in TANGENT SPACE.

ATTRIB texPos		= fragment.texcoord[6];		# texture coordinates
ATTRIB eyeVec		= fragment.texcoord[7];		# texture coordinates

PARAM misc		= { 0, 0.5, 1.0, 2.0 };

OUTPUT outColour	= result.color;

TEMP temp;
TEMP newPos;
TEMP texDiff, texGlow, texNorm;
TEMP eye, reflection, normal, height, light, gloss, attncol;
TEMP dotLN;
TEMP diffuse, specular;
TEMP colBase, colStripe, wBase, wStripe, colour;

### NORMALISE EYE VECTOR

DP3 eye, eyeVec, eyeVec; 
RSQ eye, eye.x;
MUL eye, eyeVec, eye;

### GET NORMAL AND HEIGHT FROM TEXTURE

TEX texNorm, texPos, texture[2], 2D;
MOV height, texNorm.a;

### UNPACK AND RE-NORMALISE NORMAL

MAD temp, texNorm, 2, -1;
DP3 normal, temp, temp; 
RSQ normal, normal.x;
MUL normal, temp, normal;

### CALCULATE NEW TEXTURE COORDINATE AND GET SHIFTED TEXTURES (PARALLAX MAPPING)

# shift texture coordinate (offset limited parallax mapping)
#MUL height, height, program.local[3];		# scale defined in shader pass
#SUB height, height, program.local[4];		# bias defined in shader pass
#MAD newPos, height, eye, texPos;

# shift texture coordinate (offset limited parallax mapping with slope information)
MUL height, height, program.local[3];		# scale defined in shader pass
SUB height, height, program.local[4];		# bias defined in shader pass
MUL temp, height, normal.z;
MAD newPos, temp, eye, texPos;

# sample textures
TEX texDiff, newPos, texture[0], 2D;
TEX texGlow, newPos, texture[1], 2D;
TEX texNorm, newPos, texture[2], 2D;

### UNPACK AND RE-NORMALISE NEW NORMAL

MAD temp, texNorm, 2, -1;
DP3 normal, temp, temp; 
RSQ normal, normal.x;
MUL normal, temp, normal;

### CALCULATE GLOSSINESS FROM TEXTURE

POW temp, texGlow.r, {3}.x;
MAD gloss, temp, program.local[5], program.local[6];

### CALCULATE LIGHTING FOR LIGHT 0

# attenuate light colour
MUL attncol, state.light[0].diffuse, fragment.texcoord[0].a;

# re-normalise light vector
DP3 light, fragment.texcoord[0], fragment.texcoord[0]; 
RSQ light, light.x;
MUL light, fragment.texcoord[0], light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MUL_SAT diffuse, dotLN, attncol;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MUL specular, temp, attncol;

### CALCULATE LIGHTING FOR LIGHT 1

# attenuate light colour
MUL attncol, state.light[1].diffuse, fragment.texcoord[1].a;

# re-normalise light vector
DP3 light, fragment.texcoord[1], fragment.texcoord[1]; 
RSQ light, light.x;
MUL light, fragment.texcoord[1], light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

### CALCULATE LIGHTING FOR LIGHT 2

# attenuate light colour
MUL attncol, state.light[2].diffuse, fragment.texcoord[2].a;

# re-normalise light vector
DP3 light, fragment.texcoord[2], fragment.texcoord[2]; 
RSQ light, light.x;
MUL light, fragment.texcoord[2], light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

### CALCULATE LIGHTING FOR LIGHT 3

# attenuate light colour
MUL attncol, state.light[3].diffuse, fragment.texcoord[3].a;

# re-normalise light vector
DP3 light, fragment.texcoord[3], fragment.texcoord[3]; 
RSQ light, light.x;
MUL light, fragment.texcoord[3], light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

### CALCULATE LIGHTING FOR LIGHT 4

# attenuate light colour
MUL attncol, state.light[4].diffuse, fragment.texcoord[4].a;

# re-normalise light vector
DP3 light, fragment.texcoord[4], fragment.texcoord[4]; 
RSQ light, light.x;
MUL light, fragment.texcoord[4], light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

### CALCULATE LIGHTING FOR LIGHT 5

# attenuate light colour
MUL attncol, state.light[5].diffuse, fragment.texcoord[5].a;

# re-normalise light vector
DP3 light, fragment.texcoord[5], fragment.texcoord[5]; 
RSQ light, light.x;
MUL light, fragment.texcoord[5], light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

### CALCULATE LIGHTING FOR LIGHT 6

# attenuate light colour
MUL attncol, state.light[6].diffuse, fragment.color.primary.a;

# unpack and re-normalise light vector
MAD temp, fragment.color.primary, 2, -1;
DP3 light, temp, temp; 
RSQ light, light.x;
MUL light, temp, light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

### CALCULATE LIGHTING FOR LIGHT 7

# attenuate light colour
MUL attncol, state.light[7].diffuse, fragment.color.secondary.a;

# re-normalise light vector
MAD temp, fragment.color.secondary, 2, -1;
DP3 light, temp, temp; 
RSQ light, light.x;
MUL light, temp, light;

# diffuse with attenuation
DP3 dotLN, light, normal;			
MAX temp, 0, dotLN;				# prevent negative values
MAD diffuse, temp, attncol, diffuse;	

# calculate reflection vector
MUL temp, normal, dotLN;
MUL temp, temp, 2;
SUB reflection, light, temp;

# prevent back surface reflection
SGE temp, dotLN, 0;
MUL reflection, reflection, temp;

# specular with attenuation
DP3_SAT temp, reflection, eye;			# prevent negative values
POW temp, temp.x, gloss.x;
MUL temp, temp, texGlow.b;
MAD specular, temp, attncol, specular;

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
SUB wBase, misc.z, texDiff.a;
SUB wStripe, misc.z, texGlow.a;

# average the team colour and base texture
LRP temp.rgb, wBase, colBase, texDiff;
LRP colour, wStripe, colStripe, temp;

### ADD GLOW

MAD diffuse, texGlow.g, program.local[0], diffuse;	# scale intensity by external glow colour multiplier

### ADD AMBIENT

ADD diffuse, diffuse, state.lightmodel.ambient;

### COMBINE LIGHTING AND SHADING

MAD outColour, colour, diffuse, specular;

END
