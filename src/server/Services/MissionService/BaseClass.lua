local BaseClass = {}

function BaseClass:__call(...)
    local object = {}
    setmetatable(object, self)

    if self.__init then
        self.__init(object, ...)
    end

    return object
end

function BaseClass.class(newClass)
    newClass.__index = newClass
    return setmetatable(newClass, BaseClass)
end

return BaseClass