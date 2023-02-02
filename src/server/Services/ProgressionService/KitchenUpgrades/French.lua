local French = {
    ["Jump Amount"] = {
        Type = "x";
        Max = 3;
        [1] = { Value = 1; Price = 0; };
        [2] = { Value = 2; Price = 15000; };
        [3] = { Value = 3; Price = 30000; };
    };
    ["Cook Speed"] = {
        Type = "x";
        Max = 6;
        [1] = { Value = 1; Price = 0; };
        [2] = { Value = 1.1; Price = 2500; };
        [3] = { Value = 1.2; Price = 3000; };
        [4] = { Value = 1.3; Price = 5000; };
        [5] = { Value = 1.4; Price = 10000; };
        [6] = { Value = 1.5; Price = 15000; };
    };
    ["Boost Stamina"] = {
        Type = "%";
        Max = 6;
        [1] = { Value = 100; Price = 0; }; --100%
        [2] = { Value = 120; Price = 3000; };
        [3] = { Value = 140; Price = 6000; };
        [4] = { Value = 160; Price = 9000; };
        [5] = { Value = 180; Price = 12000; };
        [6] = { Value = 200; Price = 15000; }; --200%
    };
    ["Order Duration"] = {
        Type = " minutes";
        Max = 4;
        [1] = { Value = 120; Price = 120; };
        [2] = { Value = 180; Price = 0; };
        [3] = { Value = 240; Price = 0; };
        [4] = { Value = 300; Price = 0; };
        [5] = { Value = 360; Price = 0; };
        [6] = { Value = 420; Price = 0; };
    };
    ["Extra Health"] = {
        Type = " HP";
        Max = 4;
        [1] = { Value = 100; Price = 0; }; --100%
        [2] = { Value = 120; Price = 3000; };
        [3] = { Value = 140; Price = 6000; };
        [4] = { Value = 160; Price = 9000; };
        [5] = { Value = 180; Price = 12000; };
        [6] = { Value = 200; Price = 15000; }; --200%
    };
    ["Multitasking"] = {
        Type = "x";
        Max = 2;
        [1] = { Value = false; Price = 0; };
        [2] = { Value = true; Price = 12000; };
    };
    ["Cooking Perfection"] = {
        Type = "x";
        Max = 4;
        [1] = { Value = false; Price = 0; };
        [2] = { Value = true; Price = 35000; };
    };
}

return French