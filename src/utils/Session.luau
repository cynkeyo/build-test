local constants = require(script.Parent.Parent.constants)
local dateFormat = constants.PLUGIN_DATE_FORMAT
local types = require(script.Parent.Parent.types)
local deepClone = require(script.Parent.deepClone)

local Session = {}

Session.__index = Session

type members = {
	_date: types.dateType,
	_data: { [string]: types.serializedInstance },
}

export type SerializedSession = members

export type ClassType = typeof(setmetatable({} :: members, {} :: typeof(Session)))

function Session.new(): ClassType
	local self = {
        _date = os.date(dateFormat),
		_data = {},
	}

	setmetatable(self, Session)

	return self
end

function Session.fromSerialization(serialized: SerializedSession): ClassType
    local self = {
        _date = serialized._date,
        _data = serialized._data
    }

    setmetatable(self, Session)

    return self
end

function Session.serialize(self: ClassType): SerializedSession
	return {
        _date = self._date,
        _data = deepClone(self._data)
    }
end

function Session.getCreationDate(self: ClassType): types.dateType
    return self._date
end

function Session.getInstanceDataDict(self: ClassType)
    return self._data
end

function Session.getInstanceDataFromId(self: ClassType, instanceId: string): types.serializedInstance?
    return self._data[instanceId]
end

function Session.addInstanceData(self: ClassType, instanceData: types.serializedInstance, instanceId: string)
	self._data[instanceId] = instanceData
end

function Session.removeInstanceData(self: ClassType, instanceId)
	self._data[instanceId] = nil
end

function Session.destroy(self: ClassType)
	table.clear(self :: any)
	setmetatable(self :: any, nil)
	table.freeze(self)
end

return Session
