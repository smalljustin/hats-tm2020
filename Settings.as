[Setting category="General" name="Enable hats"]
bool g_visible = true;

bool Setting_General_HideWhenNotPlaying = true;

[Setting category="General" name="Use Circular Hat"]
bool USE_CIRCLE_HAT = true;

[Setting category="General" name="Use Top Hat"]
bool TOP_HAT = false;

[Setting category="General" name="Use cat ears"]
bool CAT_EARS = false;

[Setting category="General" name="Use Peaky Blinders cap"]
bool PEAKY_BLINDERS = false;

[Setting category="Player View" name="Use currently viewed player"]
bool UseCurrentlyViewedPlayer = true;

[Setting category="Player View" name="Player index to grab" drag min=0 max=100]
int player_index = 0;

[Setting category="General" name="Major axis" min=0 max=0.5]
float HAT_MAJOR_AXIS = .271;

[Setting category="General" name="Minor axis" drag min=0 max=0.5]
float HAT_MINOR_AXIS = 0.403;

[Setting category="General" name="Starting y axis position Base" drag min=0 max=3]
float HAT_Y_OFFSET = 0.798;

[Setting category="General" name="Starting y axis position L2" drag min=0 max=1]
float HAT_Y_OFFSET_2 = 0.065;

[Setting category="General" name="Number of hat layers" drag min=0 max=10]
int NUM_HAT_LAYERS = 6;

[Setting category="General" name="Starting x axis position" drag min=-1 max=1]
float HAT_X_OFFSET = 0.141;

[Setting category="General" name="Chi base" drag min=-3.1415926 max=3.1415926] 
float CHI_BASE = -1.626;

[Setting category="Circular Hat" name="Number steps" drag min=3 max=50]
int HAT_STEPS = 12;

[Setting category="Circular Hat" name="Stripe Num Steps" drag min=1 max=8]
int HAT_STRIPE_STEP = 4;

[Setting category="Circular Hat" name="Hat Color 1" color]
vec4 HAT_COLOR_1(125.0/255.0, 19.0/255.0, 36.0/255.0, 200.0/255.0);

[Setting category="Circular Hat" name="Hat Color 2" color]
vec4 HAT_COLOR_2(21.0/255.0, 32.0/255.0, 80.0/255.0, 200.0/255.0);

[Setting category="Circular Hat" name="Hat Color 3" color]
vec4 HAT_COLOR_3(250.0/255.0, 250.0/255.0, 250.0/255.0, 70.0/255.0);

[Setting category="General" name="Enable stripes"]
bool ENABLE_STRIPES = false;

[Setting category="Custom Hats" name="Edit Object Override"] 
bool OBJECT_EDIT_OVERRIDE = false;

[Setting category="Custom Hats" name="Object scale override" min=0.001 max=1]
float SCALE_OVERRIDE = 0.5;

[Setting category="Custom Hats" name="X axis override" min=0.001 max=1]
float X_AXIS_OVERRIDE = 0;

[Setting category="Custom Hats" name="Y axis override" min=0.001 max=1]
float Y_AXIS_OVERRIDE = 0;

[Setting category="Custom Hats" name="Z axis override" min=0.001 max=1]
float Z_AXIS_OVERRIDE = 0;

[Setting category="Custom Hats" name="Color override" color]
vec4 COLOR_OVERRIDE = vec4(1, 1, 1, 1);

[Setting category="Custom Hats" name="Width override" min=0.1 max=4]
float WIDTH_OVERRIDE = 1;