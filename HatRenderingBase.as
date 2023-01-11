// Common Stuff:
const string DEFAULT_LOG_NAME = Meta::ExecutingPlugin().Name;

void log(const string & in msg) {
    log(DEFAULT_LOG_NAME, msg);
}
void log(const string & in name,
    const string & in msg) {
    print("[\\$669" + name + "\\$z] " + msg);
}


class HatRenderingBase {
    array<ObjRender> activeObjRenders; 
    string active_map_uuid;
    bool running = false;

    int refresh_idx = 0;

    HatRenderingBase() {}

    void update(string in_map_uuid, CSceneVehicleVis @[] visStates) {
        if (in_map_uuid == active_map_uuid && in_map_uuid != "") {
            if (running) {
                refresh_idx += 1;
            } else {
                running = true;
                refresh_idx = 0;
            }
            handleRefresh(visStates);
        } else {
            running = false;
            activeObjRenders.RemoveRange(0, activeObjRenders.Length - 1);
            active_map_uuid = in_map_uuid;
        }
    }

    void handleRefresh(CSceneVehicleVis @[] visStates) {
        if (refresh_idx % 100 != 0) {
            return;
        }
        array<ObjRender> toBeAddedObjs();
        for (int i = 0; i < visStates.Length; i++) {
            bool matched = false;
            for (int j = 0; j < activeObjRenders.Length; j++) {
                if (activeObjRenders[j].visState is visStates[i].AsyncState) {
                    matched = true;
                }
            }
            if (!matched) {
                toBeAddedObjs.InsertLast(ObjRender("cat_ears.obj", visStates[i].AsyncState));
            }
        }
        for (int i = 0; i < toBeAddedObjs.Length; i++) {
            activeObjRenders.InsertLast(toBeAddedObjs[i]);
        }

        log(tostring(activeObjRenders.Length));
    }

    void Render(CSceneVehicleVis @[] visStates) {
        if (!running) {
            return;
        }

        for (int i = 0; i < visStates.Length; i++) {
            for (int j = 0; j < activeObjRenders.Length; j++) {
                if (visStates[i].AsyncState is activeObjRenders[j].visState) {
                    activeObjRenders[j].render();
                }
            }
        }
    }
}