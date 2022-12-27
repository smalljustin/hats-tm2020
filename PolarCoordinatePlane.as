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

    CircularHat circularHat();

    PolarCoordinatePlane() {
        this.tssIdx = 0;
    }

    vec3 offsetHatPoint(vec3 point, float y_offset, float x_offset) {
        point += visState.Dir * -x_offset;
        point += visState.Up * y_offset;

        return point;
    }

    void renderHat() {
        array<array<vec3>> pointArrays();

        for (int i = 0; i <= 1; i++) {
            array<vec3> points();
            for (float theta = 0; theta < 4 * HALF_PI; theta += HALF_PI / HAT_STEPS) {
                vec3 point = projectCylindricalVec(visState.Left, circularHat.getPoint(i, theta));
                points.InsertLast(offsetHatPoint(point, HAT_Y_OFFSET, HAT_X_OFFSET));
            }
            pointArrays.InsertLast(points);
        }


        for (int i = 1; i < NUM_HAT_LAYERS; i++) {
            array<vec3> points_l1;
            for (float theta = 0; theta < 4 * HALF_PI; theta += HALF_PI / HAT_STEPS) {
                vec3 point = projectCylindricalVec(visState.Left, circularHat.getPoint(2, theta));
                points_l1.InsertLast(offsetHatPoint(point, HAT_Y_OFFSET + HAT_Y_OFFSET_2 * i, HAT_X_OFFSET));
            }
            pointArrays.InsertLast(points_l1);
        }



        if (ENABLE_STRIPES) {

        int idx = 0;

        for (int j = 0; j < pointArrays[0].Length; j += HAT_STRIPE_STEP) {
            nvg::BeginPath();
            nvg::MoveTo(Camera::ToScreenSpace(pointArrays[0][j]));
            for (int i = 0; i < pointArrays.Length; i++) {
                nvg::LineTo(Camera::ToScreenSpace(pointArrays[i][j]));
            }
            vec3 endPoint = offsetHatPoint(visState.Position, HAT_Y_OFFSET + HAT_Y_OFFSET_2 * (NUM_HAT_LAYERS - 1), HAT_X_OFFSET);
            nvg::LineTo(Camera::ToScreenSpace(endPoint));

            if (idx % 2 == 0) {
            nvg::StrokeColor(HAT_COLOR_1);
            } else {
            nvg::StrokeColor(HAT_COLOR_2);
            }

            idx += 1;
            nvg::StrokeWidth(4);
            nvg::Stroke();
            nvg::ClosePath();
        }
        }


        for (int i = 0; i < pointArrays.Length; i++) {
            renderPointArray(pointArrays[i], HAT_COLOR_3);
        }
    }

    void renderPointArray(array<vec3> points, vec4 color) {

        if (points.Length == 0) {
            return;
        }
        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(points[0]));
    
        for (int i = 1; i < points.Length; i++) {
            nvg::LineTo(Camera::ToScreenSpace(points[i]));
        }

        nvg::LineTo(Camera::ToScreenSpace(points[0]));

        nvg::StrokeColor(color);
        nvg::StrokeWidth(4);
        nvg::Stroke();
        nvg::ClosePath();

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

    vec3 projectPolar(vec3 basis, float r, float theta) {
        return projectCylindrical(basis, r, theta, 0);
    }

    vec3 projectCylindricalVec(vec3 basis, vec3 vec) {
        return projectCylindrical(basis, vec.x, vec.y, vec.z);
    }

    vec3 projectCylindrical(vec3 basis, float r, float theta, float height) {
        // vec3 angle_cross = getAngleCylindrical(basis, theta);
        vec3 p = visState.Position;
        p += visState.Up * height;
        p += visState.Dir * Math::Sin(theta) * r;
        p += visState.Left * Math::Cos(theta) * r;

        return p;
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
        @this.visState = @visState;
    }
}