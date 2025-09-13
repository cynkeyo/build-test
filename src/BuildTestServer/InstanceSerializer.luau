local types = require(script.Parent.Parent.types)
local MInstance: types.MInstanceModule = require(script.Parent.MInstance)

local SERIALIZATION_SETTINGS = {
	IncludeDescendants = false,
	CompressSerializedData = true,
	EncodeInBase94 = true,
	AnnoyingConsolePrints = false,
	UseLegacySlowCompressor = false,
	IncludeAttributes = false,
	DisallowedProperties = nil,
}

local DESERIALIZATION_SETTINGS = {
	IsDataCompressed = true,
	IsBase94Encoded = true,
	AnnoyingConsolePrints = false,
	IsCompressedWithLegacyCompressor = false,
	ProperlyDeserializeMeshParts = true,
	ParentInstanceWhileDeserializing = nil,
}

local InstanceSerializer = {}

function InstanceSerializer.serializeInstance(instance: Instance): types.serializedInstance
	return {
		data = MInstance.SerializeInstance(instance, SERIALIZATION_SETTINGS),
		name = instance.Name,
        className = instance.ClassName
	}
end

function InstanceSerializer.deserializeInstance(serializedInstance: types.serializedInstance, deserializeTo: Instance?): Instance
	return MInstance.DeserializeInstance(serializedInstance.data, DESERIALIZATION_SETTINGS, deserializeTo)
end

return InstanceSerializer
