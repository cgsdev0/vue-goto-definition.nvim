local config = require("vue-goto-definition.config")
local import = require("vue-goto-definition.import")
local utils = require("vue-goto-definition.utils")
local locationlist = require("vue-goto-definition.locationlist")

local M = {}

local lsp_definition = vim.lsp.buf.definition

local _items = {}

function M.setup(framework, patterns)
	local group = vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = config.get_opts().filetypes,
		group = group,
		callback = function()
			local on_list = {
				on_list = function(list)
					if not list or not list.items or #list.items == 0 or not utils.vue_lsp_loaded() then
						return
					end
					vim.list_extend(_items, list.items)
					vim.defer_fn(function()
						if #_items == 0 then
							return
						end
						--  BUG: 2024-03-20 - Path is not resolved when calling definition
						--  on auto imported pinia store
						local path = import.get_path(_items, patterns, framework)
						if path then
							vim.cmd.edit(path)
						else
							locationlist.open(_items, patterns)
						end
					end, config.get_opts().defer)
				end,
			}
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.buf.definition = function(opts)
				_items = {}
				opts = opts or {}
				opts = vim.tbl_extend("keep", opts, on_list)
				lsp_definition(opts)
			end
		end,
	})
end

return M
