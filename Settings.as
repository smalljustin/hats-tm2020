[Setting category="General" name="Enable utility"]
bool g_visible = true;

bool Setting_General_HideWhenNotPlaying = true;

[Setting category="Player View" name="Use currently viewed player"]
bool UseCurrentlyViewedPlayer = true;

[Setting category="Player View" name="Player index to grab" drag min=0 max=100]
int player_index = 0;

[Setting category="Circular Hat" name="Major axis" min=0 max=0.5]
float HAT_MAJOR_AXIS = .271;

[Setting category="Circular Hat" name="Minor axis" drag min=0 max=0.5]
float HAT_MINOR_AXIS = 0.403;

[Setting category="Circular Hat" name="Starting y axis position Base" drag min=0 max=3]
float HAT_Y_OFFSET = 0.798;

[Setting category="Circular Hat" name="Starting y axis position L2" drag min=0 max=1]
float HAT_Y_OFFSET_2 = 0.065;

[Setting category="Circular Hat" name="Number of hat layers" drag min=0 max=10]
int NUM_HAT_LAYERS = 6;

[Setting category="Circular Hat" name="Starting x axis position" drag min=-1 max=1]
float HAT_X_OFFSET = 0.141;

[Setting category="Circular Hat" name="Chi base" drag min=-3.1415926 max=3.1415926] 
float CHI_BASE = -1.626;

[Setting category="Circular Hat" name="Number steps" drag min=3 max=50]
int HAT_STEPS = 14;

[Setting category="Circular Hat" name="Stripe Num Steps" drag min=1 max=8]
int HAT_STRIPE_STEP = 4;

[Setting category="Circular Hat" name="Hat Color 1" color]
vec4 HAT_COLOR_1(125.0/255.0, 19.0/255.0, 36.0/255.0, 200.0/255.0);

[Setting category="Circular Hat" name="Hat Color 2" color]
vec4 HAT_COLOR_2(21.0/255.0, 32.0/255.0, 80.0/255.0, 200.0/255.0);

[Setting category="Circular Hat" name="Hat Color 3" color]
vec4 HAT_COLOR_3(250.0/255.0, 250.0/255.0, 250.0/255.0, 70.0/255.0);

[Setting category="Circular Hat" name="Enable stripes"]
bool ENABLE_STRIPES = false;
