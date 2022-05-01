local M = {}

function fileExists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function readAll(file)
    if (fileExists(file)) then

        local f = assert(io.open(file, "rb"))
        local content = f:read("*all")
        f:close()
        return string.gsub(content, "\n", "")
    else
        return nil
    end
end

function getFFFOutfileLocation()
    local homeDir = vim.env.HOME
    local cacheLocation = '.cache'
    local outputFile = 'fff/opened_file'
    local outfile =
        string.format('%s/%s/%s', homeDir, cacheLocation, outputFile)
    return outfile
end

function deleteFFFOutfile()
    local filelocation = getFFFOutfileLocation()
    silentRunShellCommand('rm ' .. filelocation)
end

function getPickedFile()
    local outfile = getFFFOutfileLocation()
    local result = readAll(outfile)
    return result
end

function silentRunShellCommand(command)
    vim.cmd(string.format([[silent exec "! %s"]], command))
end

function M.start()
    local currentLocation = vim.fn.expand('%:p:h')

    -- make a new buffer and open it
    vim.cmd('enew')
    local buffer = vim.api.nvim_get_current_buf();
    vim.cmd('b ' .. buffer)

    -- run the fff command in the new buffer
    local command = string.format("cd %s && fff -p", currentLocation)
    vim.fn.termopen(command, {
        on_exit = function()
            -- upon exit, read the fff outfile to get the picked filed
            local pickedFile = getPickedFile()

            if (pickedFile ~= nil) then
                -- open the picked file read from the outfile
                vim.cmd(string.format('edit %s', pickedFile))
            end

            -- delete the buffer we made to contain fff since we no longer need it
            vim.cmd('bdelete ' .. buffer)

            -- delete the outfile for the next run
            deleteFFFOutfile()
        end
    })
    vim.cmd('startinsert')
end

return M
