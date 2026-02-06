local Connections = {}
Connections._storage = {}

function Connections:Connect(signal, cb, tag)
    tag = tag or "Default"

    local conn = signal:Connect(cb)

    if not Connections._storage[tag] then
        Connections._storage[tag] = {}
    end

    table.insert(Connections._storage[tag], conn)
    return conn
end

function Connections:Clean(tag)
    tag = tag or "Default"

    local list = Connections._storage[tag]
    if list then
        for _, conn in ipairs(list) do
            if conn.Connected then conn:Disconnect() end
        end
        Connections._storage[tag] = nil
    end
end

function Connections:CleanAll()
    for tag, _ in pairs(Connections._storage) do
        Connections:Clean(tag)
    end
    Connections._storage = {}
end

return Connections
