type tableType = {[any]: any}

local Table = {}

function Table.length(table: tableType): number
    local length = 0
    for _, _ in pairs(table) do
        length += 1
    end

    return length
end

return Table
