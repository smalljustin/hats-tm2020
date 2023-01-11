class ObjRender {
    bool hatRead = false;

    array < Vertex > vList();
    array < VertexNormal > vnList();
    array < Face > fList();

    string active_hat = "";
    CSceneVehicleVisState @visState;

    ObjRender() {}

    ObjRender(string active_hat, CSceneVehicleVisState @ visState) {
        this.active_hat = active_hat;
        @this.visState = @visState;
        this.readHat();
        // startnew(CoroutineFunc(this.readHat));
    }

    void readHat() {
        if (hatRead || active_hat == "") {
            return;
        }
        IO::FileSource f("hats\\" + active_hat);
        float scale = 1;
        float xloc = 0;
        float yloc = 0;
        float zloc = 0;

        float width = 1;

        vec4 color(1, 1, 1, 0.7);

        while (!f.EOF()) {
            array < string > parts = f.ReadLine().Split(" ");
            if (parts.Length < 2) {
                return;
            }
            if (parts[0] == "scale") {
                scale = Text::ParseFloat(parts[1]);
            }
            if (parts[0] == "xloc") {
                xloc = Text::ParseFloat(parts[1]);
            }
            if (parts[0] == "yloc") {
                yloc = Text::ParseFloat(parts[1]);
            }
            if (parts[0] == "zloc") {
                zloc = Text::ParseFloat(parts[1]);
            }
            if (parts[0] == "color") {
                color = Text::ParseHexColor(parts[1]);
            }
            if (parts[0] == "width") {
                width = Text::ParseFloat(parts[1]);
            }
            if (parts[0] == "v") {
                vList.InsertLast(Vertex(parts));
            } 
            if (parts[0] == "vn") {
                vnList.InsertLast(VertexNormal(parts));
            }
            if (parts[0] == "f") {
                fList.InsertLast(Face(parts));
            }
        }

        float maxVLength = 0;

        for (int i = 0; i < vList.Length; i++) {
            vList[i].scale = scale;
            vList[i].xloc = xloc;
            vList[i].yloc = yloc;
            vList[i].zloc = zloc;
            vList[i].color = color;
            vList[i].width = width;
            maxVLength = Math::Max(maxVLength, vList[i].toVec().Length());
        }

        for (int i = 0; i < vList.Length; i++) {
            vList[i].applyFactor(1 / maxVLength);
        }
        hatRead = true;
    }

    void render() {
        if (active_hat == "" || !hatRead) {
            return;
        }

        float w = vList[0].width;
        if (OBJECT_EDIT_OVERRIDE) {
            w = WIDTH_OVERRIDE;
        }

        bool shouldRender = true;

        for (int i = 0; i < fList.Length; i++) {
            shouldRender = true;

            Face f = fList[i];
            Vertex v1 = vList[f.v1 - 1];
            Vertex v2 = vList[f.v2 - 1];
            Vertex v3 = vList[f.v3 - 1];

            array < vec2 > points();

            points.InsertLast(Camera::ToScreenSpace(
                projectHatSpace(visState, v1)
            ));

            points.InsertLast(Camera::ToScreenSpace(
                projectHatSpace(visState, v2)
            ));

            points.InsertLast(Camera::ToScreenSpace(
                projectHatSpace(visState, v3)
            ));

            points.InsertLast(Camera::ToScreenSpace(
                projectHatSpace(visState, v1)
            ));

            if (!shouldRender) {
                continue;
            }

            nvg::BeginPath();
            nvg::MoveTo(points[0]);

            for (int i = 1; i < points.Length; i++) {
                nvg::LineTo(points[i]);
            }

            if (OBJECT_EDIT_OVERRIDE) {
                nvg::StrokeColor(COLOR_OVERRIDE);
                nvg::StrokeWidth(w);
            } else {
                nvg::StrokeColor(v1.color);
                nvg::StrokeWidth(w);
            }
            nvg::Stroke();
            nvg::ClosePath();
        }

    }
    vec3 projectHatSpace(CSceneVehicleVisState @ visState, Vertex point) {
        vec3 vertexPoint = point.toVec();
        if (OBJECT_EDIT_OVERRIDE) {
            vertexPoint *= SCALE_OVERRIDE;
        } else {
            vertexPoint *= point.scale;
        }
        vec3 res = offsetHatPoint(visState, visState.Position + (visState.Left * vertexPoint.x) + (visState.Up * vertexPoint.y) + (visState.Dir * vertexPoint.z), HAT_Y_OFFSET, HAT_X_OFFSET);

        if (OBJECT_EDIT_OVERRIDE) {
            res += (visState.Left * X_AXIS_OVERRIDE);
            res += (visState.Up * Y_AXIS_OVERRIDE);
            res += (visState.Dir * Z_AXIS_OVERRIDE);
        } else {
            res += (visState.Left * point.xloc);
            res += (visState.Up * point.yloc);
            res += (visState.Dir * point.zloc);
        }

        return res;
    }

    vec3 offsetHatPoint(CSceneVehicleVisState @ visState, vec3 point, float y_offset, float x_offset) {
        point += visState.Dir * -x_offset;
        point += visState.Up * y_offset;
        return point;
    }

}