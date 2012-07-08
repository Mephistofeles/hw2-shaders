!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

### UNUSED SHADER - BLANK PLACE HOLDER

PARAM miscValues  = { 0, 0.5, 1, 2 };
OUTPUT outColour = result.color;
MOV outColour, miscValues.y;

END 
