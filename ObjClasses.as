class Vertex {
    float x, y, z;

    float scale = 1;
    float xloc = 0;
    float yloc = 0;
    float zloc = 0;
    vec4 color(1, 1, 1, .7);
    float width = 1;

    Vertex() {}
    Vertex(array<string> parts) {
        x = Text::ParseFloat(parts[1]);
        y = Text::ParseFloat(parts[2]);
        z = Text::ParseFloat(parts[3]);
    }

    string toString() {
        return "VERTEX:\tx=" + tostring(x) + "\ty=" + tostring(y)  + "\tz=" + tostring(z);
    }

    vec3 toVec() {
        return vec3(x, y, z);
    }
}


class VertexNormal {
    float x, y, z;

    VertexNormal() {}
    VertexNormal(array<string> parts) {
        x = Text::ParseFloat(parts[1]);
        y = Text::ParseFloat(parts[2]);
        z = Text::ParseFloat(parts[3]);
    }

    string toString() {
        return "VertexNormal:\tx=" + tostring(x) + "\ty=" + tostring(y)  + "\tz=" + tostring(z);
    }

    vec3 toVec() {
        return vec3(x, y, z);
    }
}

class Face {
    int v1, vn1, v2, vn2, v3, vn3;

    Face() {}
    Face(array<string> parts) {
        array<string> p1 = parts[1].Split("/");
        v1 = Text::ParseInt(p1[0]);
        vn1 = Text::ParseInt(p1[2]);
        array<string> p2 = parts[2].Split("/");
        v2 = Text::ParseInt(p2[0]);
        vn2 = Text::ParseInt(p2[2]);
        array<string> p3 = parts[3].Split("/");
        v3 = Text::ParseInt(p3[0]);
        vn3 = Text::ParseInt(p3[2]);
    }

    string toString() {
        return "Face:\tv1=" + tostring(v1) + "\tvn1=" + tostring(vn1) + "\tv2=" + tostring(v2) + "\tvn2=" + tostring(vn2) + "\tv3=" + tostring(v3) + "\tvn3=" + tostring(vn3);
    }
}