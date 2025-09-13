local types = require(script.Parent.Parent.types)

function formatDate(date: types.dateType): string
	return `{date.year}-{date.month}-{date.day} {date.hour}:{date.min}:{date.sec}`
end

return formatDate
