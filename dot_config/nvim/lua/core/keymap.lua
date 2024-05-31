local disable_keys = {'<Up>', '<Down>', '<Left>', '<Right>'}

for _, key in ipairs(disable_keys) do
    vim.api.nvim_set_keymap('n', key, '<Nop>', { noremap = true, silent = true })
end

for _, key in ipairs(disable_keys) do
    vim.api.nvim_set_keymap('v', key, '<Nop>', { noremap = true, silent = true })
end

for _, key in ipairs(disable_keys) do
    vim.api.nvim_set_keymap('i', key, '<Nop>', { noremap = true, silent = true })
end
