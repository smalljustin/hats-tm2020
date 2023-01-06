class CircularHat : BaseHat {
    CircularHat() {}

    void render(CSceneVehicleVisState@ visState) override {
        array<array<vec3>> pointArrays();
        array<vec3> points();
        for (float theta = 0; theta < 4 * HALF_PI; theta += HALF_PI / HAT_STEPS) {
            vec3 point = projectCylindricalVec(visState, getPoint(0, theta));
            points.InsertLast(offsetHatPoint(visState, point, HAT_Y_OFFSET, HAT_X_OFFSET));
        }
        pointArrays.InsertLast(points);


        for (int i = 1; i < NUM_HAT_LAYERS; i++) {
            array<vec3> points_l1;
            for (float theta = 0; theta < 4 * HALF_PI; theta += HALF_PI / HAT_STEPS) {
                vec3 point = projectCylindricalVec(visState, getPoint(2, theta));
                points_l1.InsertLast(offsetHatPoint(visState, point, HAT_Y_OFFSET + HAT_Y_OFFSET_2 * i, HAT_X_OFFSET));
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
            vec3 endPoint = offsetHatPoint(visState, visState.Position, HAT_Y_OFFSET + HAT_Y_OFFSET_2 * (NUM_HAT_LAYERS - 1), HAT_X_OFFSET);
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
            this.renderPointArray(pointArrays[i], HAT_COLOR_3);
        }
    }
    }

    vec3 getPoint(int lineIdx, float pointIdx) {
        if (lineIdx == 0) {
        return line_1(pointIdx); }
        if (lineIdx == 1) {
            return line_2(pointIdx);
        }
        if (lineIdx == 2) {
            return line_3(pointIdx);
        }
        return line_1(pointIdx);
    }



    vec3 line_1(float theta) {
        // Making the brim of the hat.
        float r = elipse(theta, HAT_MAJOR_AXIS, HAT_MINOR_AXIS);
        float height = Math::Abs(Math::Sin(theta) / CHI_BASE) ** 3;
        return vec3(r, theta, height);
    }

    vec3 line_2(float theta) {
        // Making the brim of the hat.
        float r = elipse(theta, HAT_MAJOR_AXIS * .8, HAT_MINOR_AXIS * .8);
        float height = Math::Abs(Math::Sin(theta) / CHI_BASE) ** 4;
        return vec3(r, theta, height);
    }

    vec3 line_3(float theta) {
        return vec3(HAT_MINOR_AXIS * 0.5, theta, 0);
    }

    float elipse(float theta, float a, float b) {
        return (a * b) / (
            ( 0
                + (b * Math::Cos(theta)) ** 2
                + (a * Math::Sin(theta)) ** 2
            ) ** 0.5
        );
    }
