[Setting category="Antenna" name="Strength of momentum force" drag min=0.005 max=2]
float DVDT_SCALE = 0.985;

[Setting category="Antenna" name="X offset" drag min=-2 max=2]
float X_OFFSET = .393;

[Setting category="Antenna" name="Y offset" drag min=-2 max=2]
float Y_OFFSET_BASE = 0.592; 

[Setting category="Antenna" name="Z offset" drag min=-2 max=2] 
float Z_OFFSET = -1.378;

[Setting category="Antenna" name="Pole length" drag min=0.05 max=1]
float POLE_LENGTH = .303; 

// [Setting category="Antenna" drag min=10 max=100]
float SPRINGYNESS = 20;

[Setting category="Antenna" name="Decay" drag min=0.001 max=0.25]
float DECAY = 0.03;

[Setting category="Antenna" name="Spring" drag min=0.1 max=10]
float SPRING = 1.274;

[Setting category="Antenna" name="Ball size" drag min=10 max=400]
float BALL_SIZE = 65.875;

[Setting category="Antenna" name="Pole thickness" min=1 max=50]
float POLE_SIZE = 10;

[Setting category="Antenna" name="Outline thickness (0 to disable)" min=0 max=50]
float OUTLINE_SIZE = 10;

[Setting category="Antenna" name="Outline color" color]
vec4 STROKE_COLOR = vec4(0, 0, 0, 0.8);

[Setting category="Antenna" name="Ball color" color]
vec4 FILL_COLOR = vec4(0.8, 0.8, 0.8, 1);

[Setting category="Antenna" name="Pole color" color]
vec4 POLE_COLOR = vec4(0, 0, 0, 0.8);

[Setting category="Antenna" name="Frames of smoothing" drag min=1 max=100]
int ROLLING_PERIOD = 4;

[Setting category="Antenna" name="Maximum speed" drag min=0.001 max=0.1]
float MAX_KE_VAL = 0.02;

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
        if (isRespawn()) {
            kineticEnergy = vec3(0);
            position = vec3(0);
            for (int i = 0; i < ROLLING_PERIOD; i++) {
                positionArr[i] = vec3(0);
            }
            return;
        }

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
        
        kineticEnergy = clampVec3(kineticEnergy, vec3(-MAX_KE_VAL), vec3(MAX_KE_VAL));
        position = clampVec3(position, -MAX_KE_VAL, MAX_KE_VAL);
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

        vec3 CAR_OFFSET = vec3(visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * Y_OFFSET_BASE);

        vec3 ballPos = visState.Position + o * SPRINGYNESS + CAR_OFFSET + visState.Up * POLE_LENGTH;
        vec3 basePos = visState.Position + CAR_OFFSET;

        vec3 pole = (ballPos - basePos);
        float frac = POLE_LENGTH / pole.Length();

        ballPos = visState.Position + (o * SPRINGYNESS * frac) + visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * (Y_OFFSET_BASE + POLE_LENGTH);
        
        vec3 straightUp13 = visState.Position + CAR_OFFSET + visState.Up * 0.3333 * POLE_LENGTH;
        vec3 straightUp12 = visState.Position + CAR_OFFSET + visState.Up * 0.5    * POLE_LENGTH;
        vec3 straightUp23 = visState.Position + CAR_OFFSET + visState.Up * 0.6666 * POLE_LENGTH;

        vec3 straightMidPos13 = Math::Lerp(ballPos, basePos, 0.3333);
        vec3 straightMidPos12 = Math::Lerp(ballPos, basePos, 0.5   );
        vec3 straightMidPos23 = Math::Lerp(ballPos, basePos, 0.6666);
        
        vec3 midPos13 = Math::Lerp(straightUp13, straightMidPos13, 0.3333);
        vec3 midPos12 = Math::Lerp(straightUp12, straightMidPos12, 0.5);
        vec3 midPos23 = Math::Lerp(straightUp23, straightMidPos23, 0.6666);



        if (Camera::IsBehind(ballPos)) {
            return;
        }


        vec3 cameraDist = ballPos - Camera::GetCurrentPosition();

        float ballSize = BALL_SIZE / cameraDist.Length();
        float poleSize = POLE_SIZE / cameraDist.Length();
        float outlineSize = OUTLINE_SIZE / cameraDist.Length();

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(basePos));
        nvg::BezierTo(Camera::ToScreenSpace(midPos13), Camera::ToScreenSpace(midPos23), Camera::ToScreenSpace(ballPos)); 
        nvg::StrokeColor(POLE_COLOR);
        nvg::StrokeWidth(poleSize);
        nvg::Stroke();
        nvg::ClosePath();

        nvg::BeginPath();
        nvg::Circle(Camera::ToScreenSpace(ballPos), ballSize);
        nvg::StrokeWidth(outlineSize);
        nvg::FillColor(FILL_COLOR);
        nvg::Fill();
        if (OUTLINE_SIZE > 0) {
            nvg::StrokeColor(STROKE_COLOR);
            nvg::Stroke();
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

/* respawn logic */ 

bool RUN_IS_RESPAWN;
int lastStartTime; 
int lastNumRespawns;

int numRespawns() {
    auto player = getPlayer();
    if (player is null) {
        return 0;
    }
    auto scriptPlayer = player is null ? null : cast<CSmScriptPlayer>(player.ScriptAPI);
    return scriptPlayer.Score.NbRespawnsRequested;
}
int getPlayerStartTime() {
    if (getPlayer() is null) {
        return 0;
    }
    return getPlayer().StartTime;
}
bool isRespawn() {
    bool resp = false;
    if (getPlayerStartTime() != lastStartTime) {
        resp = true;
        lastStartTime = getPlayerStartTime();
    }
    if (numRespawns() != lastNumRespawns) {
        lastNumRespawns = numRespawns();
        resp = true;
    }
    return resp; 
}
CSmArenaClient@ getPlayground() {
    return cast < CSmArenaClient > (GetApp().CurrentPlayground);
}

CSmPlayer@ getPlayer() {
    auto playground = getPlayground();
    if (playground!is null) {
        if (playground.GameTerminals.Length > 0) {
            CGameTerminal @ terminal = cast < CGameTerminal > (playground.GameTerminals[0]);
            CSmPlayer @ player = cast < CSmPlayer > (terminal.GUIPlayer);
            if (player!is null) {
                return player;
            }   
        }
    }
    return null;
}

vec3 clampVec3(vec3 val, vec3 min, vec3 max) {
    return vec3(
        Math::Clamp(val.x
                  , min.x
                  , max.x),

        Math::Clamp(val.y
                  , min.y
                  , max.y),

        Math::Clamp(val.z
                  , min.z
                  , max.z));

}