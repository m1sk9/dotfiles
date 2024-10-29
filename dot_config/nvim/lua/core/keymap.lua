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

local keymap = vim.keymap

keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')

keymap.set('n', 'sh', '<C-w>h')
keymap.set('n', 'sk', '<C-w>k')
keymap.set('n', 'sj', '<C-w>j')
keymap.set('n', 'sl', '<C-w>l')

keymap.set('i', '<C-f>', '<Right>')
keymap.set('i','jj','<Esc>')
keymap.set('n','<F1>',':edit $MYVIMRC<CR>')
