!!ARBfp1.0
OPTION ARB_precision_hint_fastest;

ATTRIB col0 = fragment.color.primary;	#diffuse interpolated color

OUTPUT outColour = result.color;

MUL outColour, col0.a, program.local[0];

END

