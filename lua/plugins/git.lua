local M = {}

function M.config()
    require('gitsigns').setup {
        signs                        = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged                 = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged_enable          = true,
        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir                 = {
            follow_files = true
        },
        auto_attach                  = true,
        attach_to_untracked          = false,
        current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts      = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,   -- Use default
        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
        preview_config               = {
            relative = 'cursor',
            border = require("gradient_border").get(),
            row = 1,
            col = 0
        },
        on_attach                    = function(bufnr)
            local gitsigns = require('gitsigns')
            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            map('n', '(', function()
                if vim.wo.diff then
                    vim.cmd.normal({ '(', bang = true })
                else
                    gitsigns.nav_hunk('prev')
                end
            end)

            map('n', ')', function()
                if vim.wo.diff then
                    vim.cmd.normal({ ')', bang = true })
                else
                    gitsigns.nav_hunk('next')
                end
            end)

            map('n', 'B', gitsigns.preview_hunk)
            map('n', 'C', function()
                local status = vim.b[bufnr].gitsigns_status_dict or {}
                local root = status.root or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
                gitsigns.blame_line({ full = true }, function()
                    vim.schedule(function()
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            if vim.api.nvim_win_is_valid(win) and vim.w[win].gitsigns_preview == 'blame' then
                                local preview_buf = vim.api.nvim_win_get_buf(win)
                                -- 使用弹窗实际展示的提交，避免查询成当前 HEAD 的分支。
                                local first_line = vim.api.nvim_buf_get_lines(preview_buf, 0, 1, false)[1] or ''
                                local sha = first_line:match('^(%x+)%s')
                                local function set_title(text)
                                    if vim.api.nvim_win_is_valid(win)
                                        and vim.api.nvim_win_get_buf(win) == preview_buf then
                                        vim.api.nvim_win_set_config(win, {
                                            title = ' Git Blame | ' .. text .. ' ', title_pos = 'center',
                                        })
                                    end
                                end
                                if sha and #sha >= 7 and not sha:match('^0+$') then
                                    set_title('最后修改分支（推断）: 查询中…')
                                    -- Git 不保存提交时的分支名；仅从直接合并该提交的记录推断。
                                    vim.system({ 'git', '-C', root, 'log', '--all', '--merges',
                                        '--format=%P%x09%s', sha .. '..' },
                                        { text = true }, function(result)
                                            vim.schedule(function()
                                                if result.code ~= 0 then
                                                    set_title('最后修改分支: 未知（查询失败）')
                                                    return
                                                end
                                                local candidates = {}
                                                for line in (result.stdout or ''):gmatch('[^\n]+') do
                                                    local parents, subject = line:match('^(.-)\t(.*)$')
                                                    local parent_list = vim.split(parents or '', ' ', { trimempty = true })
                                                    -- 只接受双亲合并的第二父提交，避免把目标分支当成来源。
                                                    if #parent_list == 2 and parent_list[2]:sub(1, #sha) == sha then
                                                        local branch = subject:match("^Merge branch '([^']+)'")
                                                            or subject:match("^Merge remote%-tracking branch '([^']+)'")
                                                            or subject:match('^Merge pull request #%d+ from [^/]+/(%S+)')
                                                        if branch then candidates[branch] = true end
                                                    end
                                                end
                                                local branches = vim.tbl_keys(candidates)
                                                if #branches == 1 then
                                                    set_title('最后修改分支（推断）: ' .. branches[1])
                                                elseif #branches > 1 then
                                                    set_title('最后修改分支: 未知（来源不唯一）')
                                                else
                                                    set_title('最后修改分支: 未知（Git 未记录）')
                                                end
                                            end)
                                        end)
                                else
                                    set_title('未提交修改（无对应分支）')
                                end
                                vim.api.nvim_set_current_win(win)
                                vim.keymap.set('n', '<Esc>', '<cmd>q<CR>', { buffer = preview_buf, silent = true })
                                break
                            end
                        end
                    end)
                end)
            end)
            map('n', '\\g', gitsigns.diffthis)
        end
    }
end

return { "lewis6991/gitsigns.nvim", event = "CursorHold", config = M.config }
