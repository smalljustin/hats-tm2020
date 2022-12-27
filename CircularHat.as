class CircularHat {
    CircularHat() {}

    int getNumLines() {
        // How many line segments do we want to include in the hat?
        return 1;
    }

    vec3 getPoint(int lineIdx, float angle) {
        if (lineIdx == 0) {
        return line_1(angle); }
        if (lineIdx == 1) {
            return line_2(angle);
        }
        if (lineIdx == 2) {
            return line_3(angle);
        }
        return line_1(angle);
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


}