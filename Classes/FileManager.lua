local HttpService = game:GetService("HttpService")

local FileManager = {}
FileManager.__index = FileManager

local function isValidString(str)
    return typeof(str) == "string" and str ~= ""
end

function FileManager.new(subPath)
    if not isValidString(subPath) then
        return nil, "Error: 'SubPath' cannot be empty."
    end

    local self = setmetatable({}, FileManager)

    local mainFolder = "PromiseHub"
    self.RootPath = mainFolder .. "/" .. subPath

    if not isfolder(mainFolder) then
        makefolder(mainFolder)
    end

    if not isfolder(self.RootPath) then
        makefolder(self.RootPath)
    end

    return self, nil
end

function FileManager:GetPath(fileName)
    if not isValidString(fileName) then
        return nil, "Error: 'FileName' cannot be empty."
    end
    return self.RootPath .. "/" .. fileName .. ".json"
end

function FileManager:Save(fileName, data)
    local filePath, pathErrMsg = self:GetPath(fileName)
    if not filePath then return false, pathErrMsg end

    if data == nil then
        return false, "Error: 'Data' cannot be nil."
    end

    if type(data) == "table" and next(data) == nil then
        return false, "Error: 'Data' cannot be empty table."
    end

    local isEncodingSucc, encodingResult = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not isEncodingSucc then
        return false, "File JSON Encode Error: " .. tostring(encodingResult)
    end

    local isWriteSucc, writeErrMsg = pcall(function()
        writefile(filePath, encodingResult)
    end)
    if not isWriteSucc then
        return false, "File Write Error: " .. tostring(writeErrMsg)
    end

    return true, nil
end

function FileManager:Load(fileName)
    local filePath, pathErrMsg = self:GetPath(fileName)
    if not filePath then return {}, pathErrMsg end

    if not isfile(filePath) then
        return {}, "File does not exist." 
    end

    local isReadSucc, fileResult = pcall(function()
        return readfile(filePath)
    end)
    if not isReadSucc then
        return {}, "File Read Error: " .. tostring(fileResult)
    end

    local isDecodeSucc, decodedResult = pcall(function()
        return HttpService:JSONDecode(fileResult)
    end)
    if not isDecodeSucc then
        return {}, "File JSON Decode Error: " .. tostring(decodedResult)
    end

    return decodedResult, nil
end

function FileManager:Delete(fileName)
    local filePath, pathErrMsg = self:GetPath(fileName)
    if not filePath then return false, pathErrMsg end

    if not isfile(filePath) then
        return false, "File does not exist." 
    end

    local isDeleteSucc, deleteErrMsg = pcall(function()
        delfile(filePath)
    end)
    if not isDeleteSucc then
        return false, "File Delete Error: " .. tostring(deleteErrMsg)
    end

    return true, nil
end

function FileManager:GetList()
    if not isfolder(self.RootPath) then return {} end

    local files = listfiles(self.RootPath)
    local fileNames = {}

    for _, file in ipairs(files) do
        local fileName = file:match("([^/\\]+)$")
        if fileName and fileName:match("%.json$") then
            local cleanName = fileName:gsub("%.json$", "")
            table.insert(fileNames, cleanName)
        end
    end

    return fileNames
end

return FileManager
