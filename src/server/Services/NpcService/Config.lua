local config = {
	CustomAvatarId = nil;

	NPC_ViewDistance = {
		Easy = 50;
		Medium = 70;
		Hard = 90;
	};
	NPC_MagnitudeDistance = {
		Easy = 50;
		Medium = 70;
		Hard = 90;
	};
	NPC_CloseMagnitudeDistance = {
		Easy = 30;
		Medium = 40;
		Hard = 50;
	};

	NPC_WalkSpeed = {
		Easy = 12;
		Medium = 16;
		Hard = 20;
	};
	NPC_RunSpeed = {
		Easy = 20;
		Medium = 26;
		Hard = 32;
	};

	AttackDifficulties = {
		Easy = {
			"Stomp";
		};
		Medium = {
			"Stomp";
			"Throw";
			"Stoves";
		};
		Hard = {
			"Stomp";
			"Throw";
			"Stoves";
			"Broom";
			"Spray";
		}
	}
}

return config