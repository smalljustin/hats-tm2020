[Setting category="Test"]
float DVDT_SCALE = 100;

[Setting category="Physics hat" drag min=-2 max=2]
float X_OFFSET = 0;

[Setting category="Physics hat" drag min=-2 max=2]
float Y_OFFSET_BASE = 0; 

[Setting category="Physics hat" drag min=0.5 max=2]
float POLE_LENGTH = 1; 

[Setting category="Physics hat" drag min=-2 max=2] 
float Z_OFFSET = 0;

class PhysicsHat : BaseHat {
    PhysicsHat() {}

    vec3 kineticEnergy;
    vec3 position;
    vec3 prevVel;
    float decay = 0.05;


    void render(CSceneVehicleVisState@ visState) override {
        doUpdate(visState);
        doRender(visState);
    }

    void doUpdate(CSceneVehicleVisState@ visState) {
        kineticEnergy *= (1 - decay);
        kineticEnergy -= position * 0.03;
        vec3 dvdt = ((visState.WorldVel - prevVel) / g_dt) / DVDT_SCALE;
        dvdt -= Math::Dot(dvdt, visState.Up) * visState.Up;
        kineticEnergy -= dvdt;
        position += kineticEnergy;
        prevVel = visState.WorldVel; 
    }

    void doRender(CSceneVehicleVisState@ visState) {
        renderBall(visState, position, vec4(1, 1, 1, 1));
    }

    void renderBall(CSceneVehicleVisState@ visState, vec3 o, vec4 c) {

        vec3 ballPos = visState.Position + o * 20 + visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * (Y_OFFSET_BASE + POLE_LENGTH);
        if (Camera::IsBehind(ballPos)) {
            return;
        }

        vec3 basePos = visState.Position + visState.Left * X_OFFSET + visState.Dir * Z_OFFSET + visState.Up * Y_OFFSET_BASE;

        vec3 cameraDist = ballPos - Camera::GetCurrentPosition();

        float ballSize = 100 / cameraDist.Length();

        nvg::BeginPath();
        nvg::Circle(Camera::ToScreenSpace(ballPos), ballSize);
        nvg::FillColor(c);
        nvg::Fill();
        nvg::ClosePath();
        
        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(basePos));
        nvg::LineTo(Camera::ToScreenSpace(ballPos));
        nvg::StrokeColor(c);
        nvg::StrokeWidth(ballSize / 10);
        nvg::Stroke();
        nvg::ClosePath();
    }
}

