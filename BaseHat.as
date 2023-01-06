class BaseHat {
    BaseHat() {}

    void render(CSceneVehicleVisState@ visState) {

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

vec3 offsetHatPoint(CSceneVehicleVisState@ visState, vec3 point, float y_offset, float x_offset) {
    point += visState.Dir * -x_offset;
    point += visState.Up * y_offset;
    return point;
}

vec3 projectHatSpace(CSceneVehicleVisState@ visState, vec3 point) {
    return offsetHatPoint(visState, visState.Position + (visState.Left * point.x) + (visState.Up * point.y) + (visState.Dir * point.z), HAT_Y_OFFSET, HAT_X_OFFSET);
}

vec3 projectCylindricalVec(CSceneVehicleVisState@ visState, vec3 vec) {
    return projectCylindrical(visState, vec.x, vec.y, vec.z);
}

vec3 projectCylindrical(CSceneVehicleVisState@ visState, float r, float theta, float height) {
    // vec3 angle_cross = getAngleCylindrical(basis, theta);
    vec3 p = visState.Position;
    p += visState.Up * height;
    p += visState.Dir * Math::Sin(theta) * r;
    p += visState.Left * Math::Cos(theta) * r;
    return p;
}

float elipse(float theta, float a, float b) {
    return (a * b) / (
        ( 0
            + (b * Math::Cos(theta)) ** 2
            + (a * Math::Sin(theta)) ** 2
        ) ** 0.5
    );
}
