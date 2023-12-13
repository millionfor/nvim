local G = require('G')
local M = {}

function M.DBUI()
    G.cmd('set laststatus=0 showtabline=0 nonu signcolumn=no nofoldenable')
    G.cmd('exec "DBUI"')
end

function M.config()
    G.g.db_ui_save_location = '~/.cache'
    G.g.db_ui_use_nerd_fonts = 1
    G.g.db_ui_force_echo_notifications = 1
    G.g.db_ui_table_helpers = {
        -- <leader>W 保存缓冲区内容
        -- /Users/gongzijian/.local/share/nvim/site/pack/packer/opt/vim-dadbod-ui/autoload/db_ui/table_helpers.vim default :28 delete
        mysql = {
            ['↪ 添加数据'] = '# ↪ 添加数据 \
# INSERT INTO `qsm`.`qsm_` (列1, 列2, 列3, ...) VALUES (值1, 值2, 值3, ...); \
INSERT INTO `{schema}`.`{table}` (___, ___, ___) VALUES (___, ___, ___);',
            ['↪ 查列表'] = '# ↪ 查列表 \
# SELECT * from `qsm`.`qsm_` LIMIT 100; \
SELECT * from `{schema}`.`{table}` LIMIT 100;',
            ['↪ 查列表<条件>'] = '# ↪ 查列表<条件> \
# SELECT * FROM `qsm`.`qsm_` WHERE id ORDER BY 1 DESC LIMIT 100; \
SELECT * FROM `{schema}`.`{table}` WHERE id ORDER BY ___ DESC LIMIT 100;',
            ['↪ 查表字段'] = '# ↪ 查表字段 \
# DESCRIBE `qsm`.`qsm_`; \
DESCRIBE `{schema}`.`{table}`;',
            ['↪ 查字段索引'] = '# ↪ 查字段索引 \
# SHOW INDEXES FROM `qsm`.`qsm_`; \
SHOW INDEXES FROM `{schema}`.`{table}`;',
            ['↪ 更新表名'] = '# ↪ 更新表名 \
# RENAME TABLE `qsm`.`qsm_` TO `xxx`; \
RENAME TABLE `{table}` TO `___`;',
            ['↪ 更新某条数据'] = '# ↪ 更新某条数据 \
# UPDATE `qsm`.`qsm_` SET desc = `xxx` WHERE id = 1; \
UPDATE `{schema}`.`{table}` SET desc = `___` WHERE id = ___;',
            ['↪ 添加表字段'] = '# ↪ 添加表字段 \
# ALTER TABLE `qsm`.`qsm_` ADD email VARCHAR(255); \
ALTER TABLE `{schema}`.`{table}` ADD email VARCHAR(255);',
            ['↪ 删表'] = '# ↪ 删表 \
# DROP TABLE `qsm`.`qsm_`; \
DROP TABLE `{schema}`.`{table}`;',
            ['↪ 删表字段'] = '# ↪ 删表字段 \
# ALTER TABLE `qsm`.`qsm_` DROP COLUMN `email`; \
ALTER TABLE `{schema}`.`{table}` DROP COLUMN `___`;',
            ['↪ 删表某条数据'] = '# ↪ 删表某条数据 \
# DELETE FROM `qsm`.`qsm_` WHERE id = 1; \
DELETE FROM `{schema}`.`{table}` WHERE id = ___;',
        }
    }
    G.cmd('com! CALLDB lua require("pack/vim-dadbod").DBUI()')

end

function M.setup()
    -- do nothing
end

return M
