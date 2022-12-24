local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local OrderUI = Knit.CreateController { Name = "OrderUI" }

function AddOrder(orderData)
    local name, image, description = orderData.name, orderData.image, orderData.description
    
end

function RemoveOrder(orderId)
    
end

function AnimateOrder(orderFrame)
    -- makes a big notepad and display in midle and tween to the order position and make original notepad visible

end

function OrderUI:KnitStart()
    
end


function OrderUI:KnitInit()
    
end


return OrderUI
