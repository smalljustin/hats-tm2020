class PolarCoordinatePlane {
    int radius = 1;

    int NUM_SECTIONS = 100;

    int tssIdx = 0;
    int tssMax = 20;
    int tssCount = 0;
    int tssCountMax = 5;

    float slipAngle = 0;
    float opacity = 0;

    int numWheels = 8;
    int curWheel = 0;
    int numWheelTrailPoints = 50;
    int curWheelTrailPoint = 0;

    array < array < vec2 >> tssSmoothing(100, array < vec2 > (tssCountMax, vec2(0, 0)));

    array < array < vec3 >> pastWheelPoints(numWheels, array < vec3 > (numWheelTrailPoints, vec3(0, 0, 0)));

    CSceneVehicleVisState @ visState;

    string active_map_uuid;
    bool map_render_check = false;

    PolarCoordinatePlane() {
        this.tssIdx = 0;
    }

    CatEars circularHat = CatEars();

    void renderHat() {
        if (Camera::IsBehind(visState.Position)) {
            return;
        }

        if ((Camera::GetCurrentPosition() - visState.Position).LengthSquared() < 1) {
            return; 
        }

        circularHat.render(visState);
    }

    bool renderCheck() {
        return (
            Math::Abs(slipAngle) > HALF_PI / 1.5 &&
            visState.WorldVel.LengthSquared() > 100 &&
            (Math::Abs(2 * HALF_PI - Math::Abs(slipAngle)) > HALF_PI / 2) &&
            visState.FLIcing01 > 0);
    }

    void updateOpacity() {
        if (!renderCheck()) {
            if (opacity <= 0) {
                return;
            }
            opacity -= 0.025;
        } else {
            if (opacity >= 1) {
                return;
            }
            opacity += 0.025;
        }
    }

    vec4 getColor() {
        return vec4(1, 1, 1, opacity);
    }

    vec2 _toScreenSpace(vec3 next) {
        vec2 cur = Camera::ToScreenSpace(next);
        return cur;
    }

    vec3 getAngleSpherical(vec3 basis, vec3 coord) {
        coord.y += Math::Atan(basis.x / basis.z);
        coord.z += Math::Atan(basis.y / basis.z);
        vec3 angle_cross = vec3(Math::Sin(coord.y), Math::Cos(coord.z), Math::Cos(coord.y));
        return angle_cross;
    }
    vec3 getAngleCylindrical(vec3 basis, float theta) {
        theta += get_theta_base(basis);
        vec3 angle_cross = vec3(Math::Sin(theta), 0, Math::Cos(theta));
        return angle_cross;
    }


    vec3 projectSphericalOffset(vec3 basis, vec3 coord) {
        vec3 angle_cross = getAngleSpherical(basis, coord);
        return Math::Cross(visState.Up, angle_cross) * coord.x;
    }

    vec3 projectSpherical(vec3 basis, vec3 coord) {
        return visState.Position + projectSphericalOffset(basis, coord);
    }

    float get_theta_base(vec3 vec) {
        if (vec.z == 0) {
            return 0;
        }

        float t = Math::Atan(vec.x / vec.z);
        if (vec.z < 0) {
            t += 2 * HALF_PI;
        }
        return t;
    }

    void render() {
        if (visState is null) {
            return;
        }



        if (getMapUid() == active_map_uuid && !map_render_check) {
            map_render_check = true;
            return;
        }
        tssIdx = 0;
        renderHat();
    }

    float exp_falloff(float inVal) {
        if (inVal > 0) {
            inVal -= 1;
        }
        inVal *= -100;
        return 0.9 ** inVal;
    }

    void update(CSceneVehicleVisState @ visState) {
        if (visState is null) {
            return;
        }

        if (getMapUid() != active_map_uuid) {
            map_render_check = false;
            active_map_uuid = getMapUid();
        }
        @this.visState = @visState;
    }
}