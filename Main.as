HatRenderingBase@ hatRenderingBase;
float g_dt = 0;
float HALF_PI = 1.57079632679;
string surface_override = "";


void Update(float dt) {
  g_dt = dt;

  if (hatRenderingBase!is null) {
    auto app = GetApp();
    if (Setting_General_HideWhenNotPlaying) {
      if (app.CurrentPlayground!is null && (app.CurrentPlayground.UIConfigs.Length > 0)) {
        if (app.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
          return;
        }
      }
    }

    if (app!is null && app.GameScene!is null) {
      hatRenderingBase.update(getMapUid(), VehicleState::GetAllVis(app.GameScene));
    }
  }
}

string getMapUid() {
  auto app = cast < CTrackMania > (GetApp());
  if (app != null) {
    if (app.RootMap != null) {
      if (app.RootMap.MapInfo != null) {
        return app.RootMap.MapInfo.MapUid;
      }
    }
  }
  return "";
}


void Render() {
  if (!g_visible) {
    return;
  }

  if (hatRenderingBase!is null) {
    auto app = GetApp();
    if (Setting_General_HideWhenNotPlaying) {
      if (app.CurrentPlayground!is null && (app.CurrentPlayground.UIConfigs.Length > 0)) {
        if (app.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
          return;
        }
      }
    }

    if (app!is null && app.GameScene!is null) {
        hatRenderingBase.Render(VehicleState::GetAllVis(app.GameScene));
    }
  }
}

void Main() {
  @hatRenderingBase = HatRenderingBase();
}
