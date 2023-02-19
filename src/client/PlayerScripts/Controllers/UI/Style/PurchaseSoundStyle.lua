local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PurchaseSoundStyle = Knit.CreateController { Name = "PurchaseSoundStyle" }

--//Services
local MarketplaceService = game:GetService("MarketplaceService")

--//State
local Sounds = {
    [true] = game:WaitForChild("SoundService"):WaitForChild("Sfx"):WaitForChild("PurchaseSuccess"),
    [false] = game.SoundService.Sfx:WaitForChild("PurchaseFailed"),
}

--//Public Methods
function PurchaseSoundStyle:PlayPurchaseSound(Success)
    Sounds[Success]:Play();
end

function PurchaseSoundStyle:KnitStart()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        self:PlayPurchaseSound(wasPurchased);
    end)

    MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
        self:PlayPurchaseSound(isPurchased);
    end)
end

function PurchaseSoundStyle:KnitInit()
    
end

return PurchaseSoundStyle
