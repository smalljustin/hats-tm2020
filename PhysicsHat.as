[Setting category="Physics hat" drag min=0.005 max=2]
float DVDT_SCALE = 1.1017;

[Setting category="Physics hat" drag min=-2 max=2]
float X_OFFSET = .443;

[Setting category="Physics hat" drag min=-2 max=2]
float Y_OFFSET_BASE = 0.599; 

[Setting category="Physics hat" drag min=0.05 max=1]
float POLE_LENGTH = .303; 

[Setting category="Physics hat" drag min=-2 max=2] 
float Z_OFFSET = -1.378;

[Setting category="Physics hat" drag min=10 max=100]
float SPRINGYNESS = 20;

[Setting category="Physics hat" drag min=0.001 max=0.25]
float DECAY = 0.03;

[Setting category="Physics hat" name="Spring" drag min=1 max=100]
float SPRING = 1.708;

[Setting category="Physics hat" name="Ball size (not in px)" drag min=10 max=400]
float BALL_SIZE = 65.875;

[Setting category="Physics hat" name="Pole thickness (not in px)" min=1 max=50]
float POLE_SIZE = 10;

[Setting category="Physics hat" name="Outline thickness (0 to disable)" min=0 max=50]
float OUTLINE_SIZE = 10;

[Setting category="Physics hat" name="Outline color" color]
vec4 STROKE_COLOR = vec4(0.8, 0.8, 0.8, 0.9);

[Setting category="Physics hat" name="Fill color" color]
vec4 FILL_COLOR = vec4(0.8, 0.8, 0.8, 1);

[Setting category="Physics hat" name="Rolling average period (frames)" drag min=1 max=100]
int ROLLING_PERIOD = 10;

[Setting category="Physics hat" name="Max vector length" drag min=1 max=10]
float MAX_VECTOR_LENGTH = 1;

float squarePreserveScale(float vin) {
    if (vin > 0) {
        return vin * vin;
    } else {
        return - (vin * vin);
    }
}

class PhysicsHat : BaseHat {
    PhysicsHat() {}

    vec3 kineticEnergy(0);
    vec3 position(0);
    vec3 prevVel(0);
    float decay = 0.05;

    array<vec3> positionArr(100);
    int positionIdx = 0;


    void render(CSceneVehicleVisState@ visState) override {
        doUpdate(visState);
        doRender(visState);
    }

    void doUpdate(CSceneVehicleVisState@ visState) {
        kineticEnergy *= (1 - decay);

        vec3 positionForceApplication = position * SPRING; 
        positionForceApplication.x = squarePreserveScale(positionForceApplication.x);
        positionForceApplication.y = squarePreserveScale(positionForceApplication.y);
        positionForceApplication.z = squarePreserveScale(positionForceApplication.z);

        if (isVecNanOrInf(positionForceApplication)) {
            position = vec3(0);
            positionForceApplication = vec3(0);
            kineticEnergy = vec3(0);
        }

        kineticEnergy -= positionForceApplication;
        vec3 dvdt = ((visState.WorldVel - prevVel) / g_dt) / DVDT_SCALE;
        if (isVecNanOrInf(dvdt)) {
            return;
        }
        dvdt -= Math::Dot(dvdt, visState.Up) * visState.Up;
        vec3 dedt = 0.5f * dvdt; 
        dedt.x = squarePreserveScale(dedt.x);
        dedt.y = squarePreserveScale(dedt.y);
        dedt.z = squarePreserveScale(dedt.z);

        if (isVecNanOrInf(dedt)) {
            return;
        }
        kineticEnergy -= dedt;
        position += kineticEnergy;
        prevVel = visState.WorldVel;
        positionArr[positionIdx % ROLLING_PERIOD] = position;
        positionIdx += 1;
    }

    void doRender(CSceneVehicleVisState@ visState) {
        vec3 sum(0); 
        for (int i = 0; i < ROLLING_PERIOD; i++) {
            sum += positionArr[i];
        }

        renderBall(visState, sum / ROLLING_PERIOD);
    }

    void renderBall(CSceneVehicleVisState@ visState, vec3 o) {
        vec3 ballPos = visState.Position + o * SPRINGYNESS + visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * (Y_OFFSET_BASE + POLE_LENGTH);
        vec3 basePos = visState.Position + visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * Y_OFFSET_BASE;

        vec3 pole = (ballPos - basePos);
        float frac = POLE_LENGTH / pole.Length();

        ballPos = visState.Position + (o * SPRINGYNESS * frac) + visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * (Y_OFFSET_BASE + POLE_LENGTH);

        if (Camera::IsBehind(ballPos)) {
            return;
        }


        vec3 cameraDist = ballPos - Camera::GetCurrentPosition();

        float ballSize = BALL_SIZE / cameraDist.Length();
        float poleSize = POLE_SIZE / cameraDist.Length();
        float outlineSize = OUTLINE_SIZE / cameraDist.Length();

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(basePos));
        nvg::LineTo(Camera::ToScreenSpace(ballPos));
        nvg::StrokeColor(vec4(0, 0, 0, 0.8));
        nvg::StrokeWidth(poleSize);
        nvg::Stroke();
        nvg::ClosePath();

        nvg::BeginPath();
        nvg::Circle(Camera::ToScreenSpace(ballPos), ballSize);
        nvg::StrokeWidth(outlineSize);
        nvg::FillColor(FILL_COLOR);
        nvg::Fill();
        if (OUTLINE_SIZE > 0) {
            nvg::Stroke();
            nvg::StrokeColor(STROKE_COLOR);
        }
        nvg::ClosePath();
    }
}

bool isVecNanOrInf(vec3 v) {
    return 
        Math::IsInf(v.x) || 
        Math::IsInf(v.y) || 
        Math::IsInf(v.z) || 
        Math::IsNaN(v.x) || 
        Math::IsNaN(v.y) || 
        Math::IsNaN(v.z);
}