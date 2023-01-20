GraphHud @ graphHud;
float g_dt = 0;
float HALF_PI = 1.57079632679;
string surface_override = "";

Hats::API @api;
Hats::UserFactory @users;
Hats::HatFactory @hats;
bool hasCheckedAPIKey = false;


void Update(float dt) {
  g_dt = dt;

  if (graphHud!is null) {
    auto app = GetApp();
    if (Setting_General_HideWhenNotPlaying) {
      if (app.CurrentPlayground!is null && (app.CurrentPlayground.UIConfigs.Length > 0)) {
        if (app.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
          return;
        }
      }
    }

    if (app!is null && app.GameScene!is null) {
      CSceneVehicleVis @[] allStates = VehicleState::GetAllVis(app.GameScene);
      if (UseCurrentlyViewedPlayer) {
        graphHud.update(VehicleState::ViewingPlayerState());
      }
      if (allStates.Length > 0) {
        if (!UseCurrentlyViewedPlayer && (player_index < 0 || (allStates!is null && allStates.Length > player_index))) {
          graphHud.update(allStates[player_index].AsyncState);
        }
      }
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

  if (graphHud!is null) {
    auto app = GetApp();
    if (Setting_General_HideWhenNotPlaying) {
      if (app.CurrentPlayground!is null && (app.CurrentPlayground.UIConfigs.Length > 0)) {
        if (app.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
          return;
        }
      }
    }

    if (app!is null && app.GameScene!is null) {
      if (UseCurrentlyViewedPlayer) {
        graphHud.Render(VehicleState::ViewingPlayerState());
      } else {
        CSceneVehicleVis @[] allStates = VehicleState::GetAllVis(app.GameScene);
        if (allStates.Length > 0) {
          if (player_index < 0 || (allStates!is null && allStates.Length > player_index)) {
            graphHud.Render(allStates[player_index].AsyncState);
          } else {
            UI::SetNextWindowContentSize(400, 150);
            UI::Begin("\\$f33Invalid player index!");
            UI::Text("No player found within player states at index " + tostring(player_index));
            UI::Text("");
            UI::End();
          }
        }
      }
    }
  }
}

void Main() {
  @graphHud = GraphHud();
  @api = Hats::API(HATSERVER_LOCAL ? "http://localhost:8000" : "https://tm-hats.misfitmaid.com", HATSERVER_APIKEY);

    if (!hasCheckedAPIKey) {
      if (!api.checkKeyStatus()) {
          HATSERVER_APIKEY = "";
      }
      hasCheckedAPIKey = true;
  }

	if (HATSERVER_APIKEY == "" || HATSERVER_PHONE_HOME < Time::Stamp) {
		HATSERVER_APIKEY = api.fetchAPIKey();
		HATSERVER_PHONE_HOME = Time::Stamp + (86400 * 7);
	}

  @hats = Hats::HatFactory();
  @users = Hats::UserFactory();

  if (!hats.getHatsFromAPI(HATSERVER_APIKEY != "")) {
    warn("Unable to fetch hats, check network info");
  }
}

void OnSettingsChanged() {
  graphHud.onSettingsChange();
}

