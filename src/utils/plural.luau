function plural(amount: number, suffix: string?): string
	return if amount > 1 then suffix or "s" else ""
end

return plural
