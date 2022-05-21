local MapSettings = {};
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

MapSettings.Lobby = {
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(138, 138, 138);
        Brightness = 2;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(128, 128, 128);
        ShadowSoftness = 0.25;
        ClockTime = 14;
        GeographicLatitude = 41.733;
        TimeOfDay = "14:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(110, 163, 173);
        FogEnd = 600;
        FogStart = 200;

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxasset://sky/moon.jpg";
            SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex";
            SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex";
            SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex";
            SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex";
            SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex";
            SkyboxUp = "rbxasset://textures/sky/sky512_up.tex";
            StarCount = 3000;
            SunAngularSize = 21;
            SunTextureId = "rbxasset://sky/sun.jpg";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 30;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0;
            Contrast = 0.1;
            Enabled = true;
            Saturation = 0.15;
            TintColor = Color3.fromRGB(255,255,255);
            Parent = Lighting;
        };

    };
}

MapSettings.Tropical = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(130, 126, 92);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(175, 126, 69);
        ShadowSoftness = 0.2;
        ClockTime = 12;
        GeographicLatitude = 1;
        TimeOfDay = "12:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(103, 138, 159);
        FogEnd = 1000;
        FogStart = 200;

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.569;
            Density = 0.585;
            Color = Color3.fromRGB(255,255,255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 350;
            NearIntensity = 1;
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 15;
            Threshold = 1.866;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0;
            Contrast = 0.23;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(255,255,255);
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.292;
            Spread = 0;
            Parent = Lighting;
        };
    };
}

MapSettings.Candyland = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(138, 109, 137);
        Brightness = 2;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(128, 94, 72);
        ShadowSoftness = 0.2;
        ClockTime = 12;
        GeographicLatitude = 17;
        TimeOfDay = "12:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(195, 152, 222);
        FogEnd = 100000;
        FogStart = 100000;

        Atmosphere = {
            Density = 0.313;
            Offset = 0;
            Color = Color3.fromRGB(199, 104, 222);
            Decay = Color3.fromRGB(103, 92, 49);
            Glare = 10;
            Haze = 2.08;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "http://www.roblox.com/asset/?version=1&id=1013852";
            SkyboxDn = "http://www.roblox.com/asset/?version=1&id=1013853";
            SkyboxFt = "http://www.roblox.com/asset/?version=1&id=1013850";
            SkyboxLf = "http://www.roblox.com/asset/?version=1&id=1013851";
            SkyboxRt = "http://www.roblox.com/asset/?version=1&id=1013849";
            SkyboxUp = "http://www.roblox.com/asset/?version=1&id=1013854";
            StarCount = 3000;
            SunAngularSize = 21;
            SunTextureId = "rbxasset://sky/sun.jpg";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.607;
            Density = 1;
            Color = Color3.fromRGB(242, 142, 255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 15;
            Threshold = 1.866;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.05;
            Contrast = 0.2;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(242, 226, 255);
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.292;
            Spread = 0;
            Parent = Lighting;
        };
    };
}

MapSettings.Winterland = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(124, 124, 124);
        Brightness = 2;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(74, 115, 128);
        ShadowSoftness = 0.2;
        ClockTime = 0;
        GeographicLatitude = 20;
        TimeOfDay = "00:00:00";
        ExposureCompensation = 0;

        Atmosphere = {
            Density = 0.396;
            Offset = 0;
            Color = Color3.fromRGB(255, 255, 255);
            Decay = Color3.fromRGB(148, 199, 223);
            Glare = 0;
            Haze = 2.08;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 21;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.7;
            Density = 0.464;
            Color = Color3.fromRGB(126, 131, 130);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 24;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.05;
            Contrast = 0.4;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(230, 255, 234);
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.01;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.Wipeout = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(125, 114, 32);
        Brightness = 2.89;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(158, 158, 158);
        ShadowSoftness = 0.2;
        ClockTime = 14.245;
        GeographicLatitude = 40.272;
        TimeOfDay = "14:14:42";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(103, 91, 241);
        FogEnd = 2000;
        FogStart = 500;

        Atmosphere = {
            Density = 0.26;
            Offset = 0.415;
            Color = Color3.fromRGB(199, 164, 123);
            Decay = Color3.fromRGB(170, 164, 82);
            Glare = 0.92;
            Haze = 1.23;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.569;
            Density = 0.585;
            Color = Color3.fromRGB(255,255,255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = .55;
            Size = 14;
            Threshold = 1.763;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.04;
            Contrast = 0.06;
            Enabled = true;
            Saturation = 0.5;
            TintColor = Color3.fromRGB(255, 255, 255);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.012;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.Jungle = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(200, 169, 120);
        Brightness = 2.2;
        ColorShift_Bottom = Color3.fromRGB(19, 54, 130);
        ColorShift_Top = Color3.fromRGB(219, 229, 152);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(116, 190, 127);
        ShadowSoftness = 0.2;
        ClockTime = 16.708;
        GeographicLatitude = 71.818;
        TimeOfDay = "16:42:28";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(112, 127, 84);
        FogEnd = 1000;
        FogStart = 250;

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "";
            SkyboxBk = "rbxassetid://252760981";
            SkyboxDn = "rbxassetid://252763035";
            SkyboxFt = "rbxassetid://252761439";
            SkyboxLf = "rbxassetid://252760980";
            SkyboxRt = "rbxassetid://252760986";
            SkyboxUp = "rbxassetid://252762652";
            StarCount = 3000;
            SunAngularSize = 60;
            SunTextureId = "rbxassetid://1345009717";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 25;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.15;
            Contrast = 0.4;
            Enabled = true;
            Saturation = 0.14;
            TintColor = Color3.fromRGB(255, 244, 199);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.3;
            FocusDistance = 0;
            InFocusRadius = 300;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0;
            Spread = 3;
            Parent = Lighting;
        };
    };
}

MapSettings.Kingdom = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(125, 114, 32);
        Brightness = 2.89;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(158, 158, 158);
        ShadowSoftness = 0.2;
        ClockTime = 8.217;
        GeographicLatitude = 21.744;
        TimeOfDay = "08:13:01";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(112, 127, 84);
        FogEnd = 1000;
        FogStart = 250;

        Atmosphere = {
            Density = 0.26;
            Offset = 0.415;
            Color = Color3.fromRGB(199, 164, 123);
            Decay = Color3.fromRGB(170, 136, 67);
            Glare = 2.77;
            Haze = 1.23;
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.569;
            Density = 0.7;
            Color = Color3.fromRGB(255,255,255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 0.55;
            Size = 14;
            Threshold = 1.763;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.04;
            Contrast = 0.06;
            Enabled = true;
            Saturation = 0.84;
            TintColor = Color3.fromRGB(255, 255, 255);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.012;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.Desert = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(173, 145, 88);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(64, 158, 155);
        ColorShift_Top = Color3.fromRGB(104, 101, 73);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(239, 182, 219);
        ShadowSoftness = 0.2;
        ClockTime = 16.874;
        GeographicLatitude = -47.263;
        TimeOfDay = "16:52:26";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(112, 127, 84);
        FogEnd = 1000;
        FogStart = 250;

        Atmosphere = {
            Density = 0.28;
            Offset = 0;
            Color = Color3.fromRGB(173, 144, 62);
            Decay = Color3.fromRGB(180, 151, 126);
            Glare = 0.5;
            Haze = 2.08;
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.696;
            Density = 0.268;
            Color = Color3.fromRGB(106, 106, 64);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxasset://sky/moon.jpg";
            SkyboxBk = "rbxassetid://600830446";
            SkyboxDn = "rbxassetid://600831635";
            SkyboxFt = "rbxassetid://600832720";
            SkyboxLf = "rbxassetid://600886090";
            SkyboxRt = "rbxassetid://600833862";
            SkyboxUp = "rbxassetid://600835177";
            StarCount = 3000;
            SunAngularSize = 15;
            SunTextureId = "rbxasset://sky/sun.jpg";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 24;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.1;
            Contrast = 0.1;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(255, 224, 201);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.2;
            FocusDistance = 0;
            InFocusRadius = 300;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.063;
            Spread = 1;
            Parent = Lighting;
        };
    };
}

MapSettings.Cave = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(124, 47, 21);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(0, 0, 0);
        ColorShift_Top = Color3.fromRGB(0, 0, 0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(193, 193, 193);
        ShadowSoftness = 0.2;
        ClockTime = 0;
        GeographicLatitude = 23.5;
        TimeOfDay = "00:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(127, 109, 63);
        FogEnd = 10000;
        FogStart = 50;

        Atmosphere = {
            Density = 0.396;
            Offset = 0;
            Color = Color3.fromRGB(255, 170, 73);
            Decay = Color3.fromRGB(185, 94, 67);
            Glare = 0;
            Haze = 2.08;
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.769;
            Density = 0.785;
            Color = Color3.fromRGB(30, 0, 0);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 5000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 24;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.05;
            Contrast = 0.4;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(255, 225, 210);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.01;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.TropicalPotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(130, 126, 92);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(175, 126, 69);
        ShadowSoftness = 0.2;
        ClockTime = 12;
        GeographicLatitude = 1;
        TimeOfDay = "12:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(103, 138, 159);
        FogEnd = 1000;
        FogStart = 200;

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.569;
            Density = 0.585;
            Color = Color3.fromRGB(255,255,255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 350;
            NearIntensity = 1;
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 15;
            Threshold = 1.866;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0;
            Contrast = 0.23;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(255,255,255);
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.292;
            Spread = 0;
            Parent = Lighting;
        };
    };
}

MapSettings.CandyPotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(138, 109, 137);
        Brightness = 2;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(128, 94, 72);
        ShadowSoftness = 0.2;
        ClockTime = 12;
        GeographicLatitude = 17;
        TimeOfDay = "12:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(195, 152, 222);
        FogEnd = 100000;
        FogStart = 100000;

        Atmosphere = {
            Density = 0.313;
            Offset = 0;
            Color = Color3.fromRGB(199, 104, 222);
            Decay = Color3.fromRGB(103, 92, 49);
            Glare = 10;
            Haze = 2.08;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "http://www.roblox.com/asset/?version=1&id=1013852";
            SkyboxDn = "http://www.roblox.com/asset/?version=1&id=1013853";
            SkyboxFt = "http://www.roblox.com/asset/?version=1&id=1013850";
            SkyboxLf = "http://www.roblox.com/asset/?version=1&id=1013851";
            SkyboxRt = "http://www.roblox.com/asset/?version=1&id=1013849";
            SkyboxUp = "http://www.roblox.com/asset/?version=1&id=1013854";
            StarCount = 3000;
            SunAngularSize = 21;
            SunTextureId = "rbxasset://sky/sun.jpg";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.607;
            Density = 1;
            Color = Color3.fromRGB(242, 142, 255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 15;
            Threshold = 1.866;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.05;
            Contrast = 0.2;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(242, 226, 255);
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.292;
            Spread = 0;
            Parent = Lighting;
        };
    };
}

MapSettings.WinterPotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(124, 124, 124);
        Brightness = 2;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(74, 115, 128);
        ShadowSoftness = 0.2;
        ClockTime = 0;
        GeographicLatitude = 20;
        TimeOfDay = "00:00:00";
        ExposureCompensation = 0;

        Atmosphere = {
            Density = 0.396;
            Offset = 0;
            Color = Color3.fromRGB(255, 255, 255);
            Decay = Color3.fromRGB(148, 199, 223);
            Glare = 0;
            Haze = 2.08;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 21;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.7;
            Density = 0.464;
            Color = Color3.fromRGB(126, 131, 130);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 24;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.05;
            Contrast = 0.4;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(230, 255, 234);
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.01;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.WipePotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(125, 114, 32);
        Brightness = 2.89;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(158, 158, 158);
        ShadowSoftness = 0.2;
        ClockTime = 14.245;
        GeographicLatitude = 40.272;
        TimeOfDay = "14:14:42";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(103, 91, 241);
        FogEnd = 2000;
        FogStart = 500;

        Atmosphere = {
            Density = 0.26;
            Offset = 0.415;
            Color = Color3.fromRGB(199, 164, 123);
            Decay = Color3.fromRGB(170, 164, 82);
            Glare = 0.92;
            Haze = 1.23;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.569;
            Density = 0.585;
            Color = Color3.fromRGB(255,255,255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = .55;
            Size = 14;
            Threshold = 1.763;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.04;
            Contrast = 0.06;
            Enabled = true;
            Saturation = 0.5;
            TintColor = Color3.fromRGB(255, 255, 255);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.012;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.JunglePotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(200, 169, 120);
        Brightness = 2.2;
        ColorShift_Bottom = Color3.fromRGB(19, 54, 130);
        ColorShift_Top = Color3.fromRGB(219, 229, 152);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(116, 190, 127);
        ShadowSoftness = 0.2;
        ClockTime = 16.708;
        GeographicLatitude = 71.818;
        TimeOfDay = "16:42:28";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(112, 127, 84);
        FogEnd = 1000;
        FogStart = 250;

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "";
            SkyboxBk = "rbxassetid://252760981";
            SkyboxDn = "rbxassetid://252763035";
            SkyboxFt = "rbxassetid://252761439";
            SkyboxLf = "rbxassetid://252760980";
            SkyboxRt = "rbxassetid://252760986";
            SkyboxUp = "rbxassetid://252762652";
            StarCount = 3000;
            SunAngularSize = 60;
            SunTextureId = "rbxassetid://1345009717";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 25;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.15;
            Contrast = 0.4;
            Enabled = true;
            Saturation = 0.14;
            TintColor = Color3.fromRGB(255, 244, 199);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.3;
            FocusDistance = 0;
            InFocusRadius = 300;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0;
            Spread = 3;
            Parent = Lighting;
        };
    };
}

MapSettings.KingdomPotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(125, 114, 32);
        Brightness = 2.89;
        ColorShift_Bottom = Color3.fromRGB(0,0,0);
        ColorShift_Top = Color3.fromRGB(0,0,0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(158, 158, 158);
        ShadowSoftness = 0.2;
        ClockTime = 8.217;
        GeographicLatitude = 21.744;
        TimeOfDay = "08:13:01";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(112, 127, 84);
        FogEnd = 1000;
        FogStart = 250;

        Atmosphere = {
            Density = 0.26;
            Offset = 0.415;
            Color = Color3.fromRGB(199, 164, 123);
            Decay = Color3.fromRGB(170, 136, 67);
            Glare = 2.77;
            Haze = 1.23;
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.569;
            Density = 0.7;
            Color = Color3.fromRGB(255,255,255);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 0.55;
            Size = 14;
            Threshold = 1.763;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.04;
            Contrast = 0.06;
            Enabled = true;
            Saturation = 0.84;
            TintColor = Color3.fromRGB(255, 255, 255);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.012;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.DesertPotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(173, 145, 88);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(64, 158, 155);
        ColorShift_Top = Color3.fromRGB(104, 101, 73);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(239, 182, 219);
        ShadowSoftness = 0.2;
        ClockTime = 14;
        GeographicLatitude = 41.733;
        TimeOfDay = "14:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(192, 192, 192);
        FogEnd = 100000;
        FogStart = 250;

        Atmosphere = {
            Density = 0.28;
            Offset = 0;
            Color = Color3.fromRGB(173, 144, 62);
            Decay = Color3.fromRGB(180, 151, 126);
            Glare = 0.5;
            Haze = 2.08;
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.696;
            Density = 0.268;
            Color = Color3.fromRGB(106, 106, 64);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxasset://sky/moon.jpg";
            SkyboxBk = "rbxassetid://600830446";
            SkyboxDn = "rbxassetid://600831635";
            SkyboxFt = "rbxassetid://600832720";
            SkyboxLf = "rbxassetid://600886090";
            SkyboxRt = "rbxassetid://600833862";
            SkyboxUp = "rbxassetid://600835177";
            StarCount = 3000;
            SunAngularSize = 15;
            SunTextureId = "rbxasset://sky/sun.jpg";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 24;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.1;
            Contrast = 0.1;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(255, 224, 201);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.2;
            FocusDistance = 0;
            InFocusRadius = 300;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.063;
            Spread = 1;
            Parent = Lighting;
        };
    };
}

MapSettings.CavePotato = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(124, 47, 21);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(0, 0, 0);
        ColorShift_Top = Color3.fromRGB(0, 0, 0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(193, 193, 193);
        ShadowSoftness = 0.2;
        ClockTime = 0;
        GeographicLatitude = 23.5;
        TimeOfDay = "00:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(127, 109, 63);
        FogEnd = 10000;
        FogStart = 50;

        Atmosphere = {
            Density = 0.396;
            Offset = 0;
            Color = Color3.fromRGB(255, 170, 73);
            Decay = Color3.fromRGB(185, 94, 67);
            Glare = 0;
            Haze = 2.08;
            Parent = Lighting;
        };

        Clouds = {
            Name = "Clouds";
            Cover = 0.769;
            Density = 0.785;
            Color = Color3.fromRGB(30, 0, 0);
            Enabled = true;
            Parent = Workspace.Terrain;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 5000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 1;
            Size = 24;
            Threshold = 2;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.05;
            Contrast = 0.4;
            Enabled = true;
            Saturation = 0.2;
            TintColor = Color3.fromRGB(255, 225, 210);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.4;
            FocusDistance = 0;
            InFocusRadius = 400;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.01;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

MapSettings.HexagonStadium = {
    Time = 120;
    RespawnTime = 5;
    Lighting = {
        Ambient = Color3.fromRGB(99, 99, 99);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(0, 0, 0);
        ColorShift_Top = Color3.fromRGB(0, 0, 0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        OutdoorAmbient = Color3.fromRGB(111, 111, 111);
        ShadowSoftness = 0.2;
        ClockTime = 0;
        GeographicLatitude = 23;
        TimeOfDay = "00:00:00";
        ExposureCompensation = 0;

        FogColor = Color3.fromRGB(192, 192, 192);
        FogEnd = 100000;
        FogStart = 0;

        Atmosphere = {
            Density = 0.35;
            Offset = 0;
            Color = Color3.fromRGB(47, 45, 31);
            Decay = Color3.fromRGB(102, 113, 75);
            Glare = 0;
            Haze = 5;
            Parent = Lighting;
        };

        Sky = {
            Name = "Sky";
            CelestialBodiesShown = true;
            MoonAngularSize = 11;
            MoonTextureId = "rbxassetid://6444320592";
            SkyboxBk = "rbxassetid://6444884337";
            SkyboxDn = "rbxassetid://6444884785";
            SkyboxFt = "rbxassetid://6444884337";
            SkyboxLf = "rbxassetid://6444884337";
            SkyboxRt = "rbxassetid://6444884337";
            SkyboxUp = "rbxassetid://6412503613";
            StarCount = 3000;
            SunAngularSize = 11;
            SunTextureId = "rbxassetid://6196665106";
            Parent = Lighting;
        };

        BloomEffect = {
            Name = "BloomEffect";
            Enabled = true;
            Intensity = 0.65;
            Size = 46;
            Threshold = 1.085;
            Parent = Lighting;
        };

        ColorCorrectionEffect = {
            Name = "ColorCorrectionEffect";
            Brightness = 0.025;
            Contrast = 0.2;
            Enabled = true;
            Saturation = 0.05;
            TintColor = Color3.fromRGB(255, 255, 255);
            Parent = Lighting;
        };

        DepthOfFieldEffect = {
            Name = "DepthOfFieldEffect";
            Enabled = true;
            FarIntensity = 0.15;
            FocusDistance = 96.42;
            InFocusRadius = 50;
            NearIntensity = 0;
            Parent = Lighting;
        };

        SunRaysEffect = {
            Name = "SunRaysEffect";
            Enabled = true;
            Intensity = 0.01;
            Spread = 0.1;
            Parent = Lighting;
        };
    };
}

return MapSettings;