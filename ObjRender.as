class ObjRender : BaseHat {
    bool hatRead = false;

    array<Vertex> vList();
    array<VertexNormal> vnList();
    array<Face> fList();

    string active_hat = "";


    ObjRender() {
        if (TOP_HAT) {
            active_hat = "TopHat.obj";
        } else if (CAT_EARS) {
            active_hat = "cat_ears.obj";
        }
        else if (PEAKY_BLINDERS) {
            active_hat = "PeakyBlinders.obj";
        }
        else {
            active_hat = "";
        }
    }

    void onSettingsChanged() {
        hatRead = false;
        if (TOP_HAT) {
            active_hat = "TopHat.obj";
        } else if (CAT_EARS) {
            active_hat = "cat_ears.obj";
        }
        else if (PEAKY_BLINDERS) {
            active_hat = "PeakyBlinders.obj";
        }
        else {
            active_hat = "";
        }
        vList.RemoveRange(0, vList.Length);
        fList.RemoveRange(0, fList.Length);
        vnList.RemoveRange(0, vnList.Length);
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


        while(!f.EOF()) {
            array<string> parts = f.ReadLine().Split(" ");
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
        hatRead = true;

        for (int i = 0; i < vList.Length; i++) {
            vList[i].scale = scale;
            vList[i].xloc = xloc;
            vList[i].yloc = yloc;
            vList[i].zloc = zloc;
            vList[i].color = color;
            vList[i].width = width;
        }
    }

    void render(CSceneVehicleVisState@ visState) override {
        readHat();

        if (active_hat == "") {
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

            array<vec2> points();

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

            for (int i = 0; i < points.Length - 1; i++) {
                if (Math::Abs((points[i] - points[i + 1]).LengthSquared()) < w ** 2 ) {
                    shouldRender = false;
                }
            }

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
