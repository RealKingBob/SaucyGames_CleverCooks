local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local DeliveryService = Knit.CreateService {
    Name = "DeliveryService",
    Client = {
        FoodProcessed = Knit.CreateSignal();
        
    },
}

----- Services -----

local CollectionService = game:GetService("CollectionService")

----- Directories -----

local ReplicatedModules = Knit.Shared.Modules;

----- Loaded Modules -----

local ZoneAPI = require(ReplicatedModules:FindFirstChild("Zone"));

local deliverZone = ZoneAPI.new(CollectionService:GetTagged("DeliverStation"));

function DeliveryService:SubmitFood(packages)
    
end

function DeliveryService:KnitStart()
    
end


function DeliveryService:KnitInit()
    print('[DeliveryService]: Activated! [V1]')

    task.spawn(function()
        local getRadius = function(part)
            return (part.Size.Z<part.Size.Y and part.Size.Z or part.Size.Y)/2
            --In the above we are returning the smallest, first we check if Z is smaller
            --than Y, if so then we return Z or else we return Y.
        end;
        
        while task.wait(0.1) do
            for _,hitbox in pairs(CollectionService:GetTagged("DeliverStation")) do
				local radiusOfPan = getRadius(hitbox)

				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("IgnoreParts");
				overlapParams.FilterType = Enum.RaycastFilterType.Blacklist;

				local parts = workspace:GetPartBoundsInRadius(hitbox.Position, radiusOfPan, overlapParams)
				for _, part in pairs(parts) do
                    local touchedType, touchedOwner;
					if part.Parent:IsA("Model") then
						if part.Parent.PrimaryPart then
							local touchedPrimary = part.Parent.PrimaryPart;
							touchedType = touchedPrimary:GetAttribute("Type");
							touchedOwner = touchedPrimary:GetAttribute("Owner");
						end
					else
						touchedType = part:GetAttribute("Type");
						touchedOwner = part:GetAttribute("Owner");
					end

                    if touchedType and touchedOwner ~= "Default" and touchedOwner ~= "None"  then ---and deliverZone:findPart(part) == true
                        print("-", part)
                    end
					--table.insert(partsArray, part)
				end
			end
        end
    end)

end


return DeliveryService
