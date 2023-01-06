class CatEars : BaseHat {
    CatEars() {}

    void render(CSceneVehicleVisState@ visState) override {
        array<array<vec3>> pointArrays();
        array<vec3> points();

        float x = -HAT_MINOR_AXIS;
        float y = 0;
        points.InsertLast(projectHatSpace(visState, vec3(x, y, 0)));
        for (int i = 0; i < HAT_STEPS; i++) {
            x += (HAT_MINOR_AXIS * 2) / HAT_STEPS;
            y = (HAT_MAJOR_AXIS) * Math::Sqrt(1 - (x ** 2) / HAT_MINOR_AXIS ** 2);
            points.InsertLast(projectHatSpace(visState, vec3(x, y, 0)));
        }


        pointArrays.InsertLast(points);


        for (int i = 0; i < pointArrays.Length; i++) {
            renderPointArray(pointArrays[i], HAT_COLOR_3);
        }
    }
    }

    vec3 _getPoint(int lineIdx, float theta) {
        if (lineIdx == 0) {
        return _line_0(theta); }
        return vec3(0, 0, 0 );
    }

    vec3 _line_0(float theta) {
        // Making the headband. 
        // To do this: 
        // X and Z axis both just move from [high, 0] -> [0, high] in an arc. 
        // Y axis stays flat. 

        float x = elipse(theta, HAT_MAJOR_AXIS, HAT_MINOR_AXIS);
        float z = elipse(theta, HAT_MINOR_AXIS, HAT_MAJOR_AXIS);
        return vec3(x, 0, z);
    }
