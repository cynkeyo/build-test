-- HACK: since the MInstance module has some problems with linting it never returns the module type properly, 
-- so we assert it manually.
export type MInstanceModule = {
	IsClassCreatable: (className: string) -> boolean,
	SerializeInstance: (
		TargetInstance: Instance, 
		SerializationSettings: {
			IncludeDescendants: boolean,
			CompressSerializedData: boolean,
			EncodeInBase94: boolean,
			AnnoyingConsolePrints: boolean,
			UseLegacySlowCompressor: boolean,
			IncludeAttributes: boolean,
			DisallowedProperties: {[string]: {[string]: any} } | nil
		}) -> string,
	DeserializeInstance: (
		SerializedData: string, 
		DeserializationSettings: {
			IsDataCompressed: boolean,
			IsBase94Encoded: boolean,
			AnnoyingConsolePrints: boolean,
			IsCompressedWithLegacyCompressor: boolean,
			ProperlyDeserializeMeshParts: boolean,
			ParentInstanceWhileDeserializing: Instance?,
		},
		DeserializeToInstance: Instance?
	) -> Instance
}

export type BuildTestSession = {[string]: string}?

export type pluginRuntime = "studioEditMode" | "studioPlayTestClient" | "other"

return nil
