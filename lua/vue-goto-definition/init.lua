local config = require("vue-goto-definition.config")
local autocmd = require("vue-goto-definition.autocmd")

GotoDefinition = {}

function GotoDefinition.setup(opts)
	opts = opts or {}
	config.init(opts)
	autocmd.setup()
end

return GotoDefinition
