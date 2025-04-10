local G = require('G')
local M = {}

function M.config()
    -- 设置为0以使用自定义颜色，而不是随机颜色
    G.g.interestingWordsRandomiseColors = 0
    
    -- 增加最大高亮组数量
    -- 为GUI模式设置颜色（图形界面Neovim）
    G.g.interestingWordsGUIColors = {
      "#F0E68C",
      "#FFA500",
      "#DC143C",
      "#4169E1",
      "#9400D3",
      "#7B68EE",
      "#008B8B",
      "#483D8B",
      "#FF00FF",
      "#1E90FF",
      "#4682B4",
      "#FF7F50",
      "#00CED1",
      "#F2E793",
      "#008000",
      "#2E8B57",
    }
    
    -- 为终端模式设置颜色（终端中的Neovim）
    G.g.interestingWordsTermColors = {
        'red', 'green', 'blue', 'yellow', 'magenta', 'cyan',
        '202', '220', '160', '34', '199', '51',
        '214', '136', '75', '69', '93', '201'
    }
    
    -- 自定义默认高亮颜色（暗色主题）
    G.g.interestingWordsDefaultMappings = 1
    
    G.map({
        { 'n', 'ff', ":call InterestingWords('n')<cr>", {silent = true, noremap = true}},
        { 'n', 'FF', ":call UncolorAllWords()<cr>", {silent = true, noremap = true}},
        { 'n', 'n', ":call WordNavigation('forward')<cr>", {silent = true, noremap = true}},
        { 'n', 'N', ":call WordNavigation('backward')<cr>", {silent = true, noremap = true}},
    })
end

function M.setup()
    -- do nothing
end

return M

