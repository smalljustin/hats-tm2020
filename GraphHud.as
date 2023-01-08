// Common Stuff:
const string DEFAULT_LOG_NAME = Meta::ExecutingPlugin().Name;

void log(const string & in msg) {
    log(DEFAULT_LOG_NAME, msg);
}
void log(const string & in name,
    const string & in msg) {
    print("[\\$669" + name + "\\$z] " + msg);
}


class GraphHud {
    vec2 m_size;
    vec3 prev_vel;
    vec3 prev_up;

    float turn_amount;
    float centripetalForceAdder;

    CSmScriptPlayer @ script_player;
    bool script_player_active;

    int acc_smoothing = 10;
    array < float > rolling_acc(acc_smoothing, 0);
    array < float > rolling_slip(acc_smoothing, 0);
    int rolling_acc_pos = 0;

    int rolling_diff_smoothing = 10;
    array < float > rolling_up_diff(rolling_diff_smoothing, 0);
    int rolling_up_diff_pos = 0;

    array < EPlugSurfaceMaterialId > past_surfaces(200, EPlugSurfaceMaterialId::XXX_Null);
    int surface_smoothing_pos = 0;
    
    EPlugSurfaceMaterialId active_surface = EPlugSurfaceMaterialId::XXX_Null;

    int prev_width = 0;

    float opacity = 0;

    bool allStatesInitialized = false;

    PolarCoordinatePlane _polarCoordinatePlane = PolarCoordinatePlane();

    GraphHud() {
    }

    void update(CSceneVehicleVisState @ visState) {
        if (visState is null) {
            return;
        }
        _polarCoordinatePlane.update(visState);
    }
    void Render(CSceneVehicleVisState @ visState) {
        if (visState is null) {
            return;
        }
        _polarCoordinatePlane.render();
    }

    void onSettingsChange() {
        _polarCoordinatePlane.onSettingsChanged();
    }
}