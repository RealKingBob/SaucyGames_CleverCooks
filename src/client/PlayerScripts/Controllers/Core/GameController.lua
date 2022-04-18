local TweenService = game:GetService("TweenService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local GameController = Knit.CreateController { Name = "GameController" }

function GameController:ShakePart(part : Instance, duration : IntValue)
    local cycleDuration = 0.1;
	local totalDuration = duration;
	local volatility = 1;
	
	local savedPosition = part.Position;
	local tweeninfo = TweenInfo.new(
		cycleDuration,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	);

	for i = 0, totalDuration - cycleDuration, cycleDuration do
		local tween = TweenService:Create(
			part,
			tweeninfo,
			{Position = savedPosition + Vector3.new(math.random(),math.random(),math.random()).Unit * volatility}
		);
		tween:Play();
		tween.Completed:Wait();
	end

	local shakePartTween = TweenService:Create(
		part,
		tweeninfo,
		{Position = savedPosition + Vector3.new(0, -40, 0)}
	);

	shakePartTween:Play();
end

function GameController:KnitStart()
    local GameService = Knit.GetService("GameService");
	GameService.GameC:Connect(function(part, duration)
		self:ShakePart(part, duration)
	end)
end


function GameController:KnitInit()
    
end


return GameController
