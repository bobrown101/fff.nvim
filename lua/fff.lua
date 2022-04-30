local M = {}

function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function M.start()
    local homeDir = vim.env.HOME
    local cacheLocation = '.cache'
    local outputFile = 'fff/opened_file'
    local outfile = string.format('%s/%s/%s', homeDir, cacheLocation, outputFile)
    local currentLocation = vim.fn.expand('%:p:h')
    local buffer = vim.fn.termopen(string.format("EDITOR=nvim fff -p %s",
                                                 currentLocation), {
        on_exit = function()
            vim.cmd('bdelete')
            vim.cmd(string.format('edit %s', readAll(outfile)))
        end
    })
    vim.cmd('startinsert')
end

return M
