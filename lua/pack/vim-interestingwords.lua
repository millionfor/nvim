local G = require('G')

G.g.interestingWordsRandomiseColors = 1

G.g.interestingWordsGUIColors = { '#8CCBEA', '#A4E57E', '#FFDB72', '#FF7272', '#FFB3FF', '#9999FF' }

G.map({
    { 'n', 'ff', ":call InterestingWords('n')<cr>", {silent = true, noremap = true}},
    { 'n', 'FF', ":call UncolorAllWords()<cr>", {silent = true, noremap = true}},
    { 'n', 'n', ":call WordNavigation('forward')<cr>", {silent = true, noremap = true}},
    { 'n', 'N', ":call WordNavigation('backward')<cr>", {silent = true, noremap = true}},
})


