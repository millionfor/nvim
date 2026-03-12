return {
  "3rd/image.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local image = require("image")
    local logo_path = "/Users/millionfor/.config/nvim/logo.png"
    local processed_logo_path = vim.fn.stdpath("cache") .. "/logo_20.png"

    -- Function to generate 20% transparent version of the logo
    local function process_image()
      if vim.fn.executable("magick") == 1 then
        vim.fn.system(string.format("magick \"%s\" -channel A -evaluate multiply 0.12 \"%s\"", logo_path, processed_logo_path))
      elseif vim.fn.executable("convert") == 1 then
        vim.fn.system(string.format("convert \"%s\" -channel A -evaluate multiply 0.12 \"%s\"", logo_path, processed_logo_path))
      end
    end

    image.setup({
      backend = "kitty",
      integrations = {
        markdown = { enabled = true },
        neorg = { enabled = true },
      },
      window_overlap_clear_enabled = false,
      editor_only_render_when_focused = false,
    })

    local watermark = nil

    local function update_watermark()
      if watermark then
        watermark:clear()
        watermark = nil
      end

      if vim.fn.executable("magick") == 0 and vim.fn.executable("convert") == 0 then
        return
      end

      -- Ensure processed image exists
      if vim.fn.filereadable(processed_logo_path) == 0 then
        process_image()
      end

      local width = vim.o.columns
      local height = vim.o.lines

      -- Scale: 1/8 of window size
      local img_width = math.floor(width / 6)
      local img_height = math.floor(height / 6)

      -- Position: Bottom right (offsets: bottom=3, right=4)
      local x = width - img_width - 3
      local y = height - img_height - 1

      local ok, res = pcall(function()
        watermark = image.from_file(processed_logo_path, {
          x = x,
          y = y,
          width = img_width,
          height = img_height,
        })
        watermark:render()
      end)
      
      if not ok then
        vim.notify("image.nvim render failed: " .. tostring(res), vim.log.levels.WARN)
      end
    end

    -- Initial render
    vim.defer_fn(function()
      process_image()
      update_watermark()
    end, 500)

    -- Update on various window/buffer events for better adaptation
    local group = vim.api.nvim_create_augroup("ImageWatermark", { clear = true })
    vim.api.nvim_create_autocmd({ "VimResized", "WinEnter", "BufEnter" }, {
      group = group,
      callback = function()
        -- Use a timer to debounce updates and ensure window state is stable
        vim.defer_fn(update_watermark, 30)
      end,
    })
  end,
}
