-- Typst is the working format for project logs and reports, so the loop here is
-- edit in the buffer with `<leader>cp` holding a live preview open beside it.
--
-- tinymist, typst-preview.nvim, treesitter and typstyle formatting all come from
-- `lazyvim.plugins.extras.lang.typst`; everything below only adjusts defaults.
-- Export a PDF only while zathura is actually showing one.
--
-- The browser preview does not use the PDF at all: it streams from tinymist over
-- a websocket, and starts fine with exportPdf = "never". So a global "onSave"
-- writes a log.pdf that nothing ever reads. Instead exportPdf stays "never" and
-- a save exports only when this session has a live zathura for that file, which
-- makes `<leader>cv` the switch that turns the behaviour on.
--
-- tinymist.exportPdf takes a plain filesystem path. Passing a URI makes it
-- concatenate the path onto itself and fail with "output path is relative",
-- which is a confusing way to say "wrong argument type".
local opened = {}

local function pdf_for_buf(buf)
  local src = vim.api.nvim_buf_get_name(buf or 0)
  if not src:match("%.typ$") then
    return nil, "not a typst file"
  end
  return (src:gsub("%.typ$", ".pdf")), src
end

local function zathura_alive(pdf)
  local proc = opened[pdf]
  if not proc or not proc.pid then
    return false
  end
  return vim.uv.kill(proc.pid, 0) == 0
end

-- Asynchronous when given a callback, so a save does not block on the compile.
local function export(src, buf, cb)
  local client = vim.lsp.get_clients({ bufnr = buf or 0, name = "tinymist" })[1]
  if not client then
    if cb then
      cb(nil, "tinymist is not attached")
    end
    return nil, "tinymist is not attached"
  end
  local params = { command = "tinymist.exportPdf", arguments = { src } }

  if cb then
    return client:request("workspace/executeCommand", params, function(err, result)
      cb(result and result.path, err and err.message)
    end, buf or 0)
  end

  local res = client:request_sync("workspace/executeCommand", params, 20000, buf or 0)
  if not res or res.err then
    return nil, res and res.err and res.err.message or "export failed"
  end
  return res.result and res.result.path
end

-- Zathura's gg/G/nG are page commands, so a `height: auto` document -- which is
-- one page however long it grows -- makes most of its navigation inert: G goes
-- to the last page, which is page 1, which is the top. That is correct
-- behaviour and looks exactly like a broken keyboard, so say so.
--
-- Read it from the PDF rather than the source: tinymist.getDocumentMetrics
-- returns only font and span info, and the height may come from an import or a
-- computed value. MediaBox sits around 60-75% into the file, so this is a full
-- read; the files are well under a megabyte in practice.
local TALL_PAGE_MM = 500

local function page_height_mm(pdf)
  local fh = io.open(pdf, "rb")
  if not fh then
    return nil
  end
  local data = fh:read("*a")
  fh:close()
  if not data then
    return nil
  end
  local y1, y2 = data:match("/MediaBox%s*%[%s*[%d%.%-]+%s+([%d%.%-]+)%s+[%d%.%-]+%s+([%d%.%-]+)%s*%]")
  if not y1 then
    return nil
  end
  return (tonumber(y2) - tonumber(y1)) * 25.4 / 72
end

local function warn_if_unpaginated(pdf)
  local mm = page_height_mm(pdf)
  if mm and mm > TALL_PAGE_MM then
    vim.notify(
      ("This PDF is one page %.1fm tall, so zathura's page keys (G, nG, n/p) have "):format(mm / 1000)
        .. "nowhere to go; j/k and <C-d> still scroll. Set a fixed `height` on "
        .. "#set page, or read it in the browser preview with <leader>cp.",
      vim.log.levels.WARN
    )
  end
end

local function view_pdf()
  local pdf, src = pdf_for_buf()
  if not pdf then
    return vim.notify(src, vim.log.levels.WARN)
  end

  if zathura_alive(pdf) then
    return vim.notify("zathura already open for this file")
  end

  -- Nothing has exported yet if this is the first view of the session.
  if vim.fn.filereadable(pdf) == 0 then
    local path, err = export(src, 0)
    if not path then
      return vim.notify("tinymist: " .. err, vim.log.levels.ERROR)
    end
    pdf = path
  end

  warn_if_unpaginated(pdf)

  -- Zathura watches the file and reloads on change, so one window is enough
  -- for the whole session.
  opened[pdf] = vim.system({ "zathura", pdf }, { detach = true })
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.typ",
  desc = "Export PDF on save, but only while zathura is watching it",
  callback = function(ev)
    local pdf, src = pdf_for_buf(ev.buf)
    if pdf and zathura_alive(pdf) then
      export(src, ev.buf, function(_, err)
        if err then
          vim.notify("tinymist export: " .. err, vim.log.levels.ERROR)
        end
      end)
    end
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tinymist = {
          settings = {
            formatterMode = "typstyle",
            -- Never automatically: the BufWritePost autocmd above exports on
            -- save when, and only when, a zathura window is open on the file.
            exportPdf = "never",
          },
        },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>cv", view_pdf, ft = "typst", desc = "View PDF (zathura)" },
      {
        "<leader>ce",
        function()
          local _, src = pdf_for_buf()
          local path, err = export(src, 0)
          vim.notify(path and ("exported " .. path) or ("tinymist: " .. err))
        end,
        ft = "typst",
        desc = "Export PDF",
      },
    },
  },

  {
    "chomosuke/typst-preview.nvim",
    opts = {
      -- Defaults to "never", which puts a white page next to a dark colourscheme.
      invert_colors = "auto",
      follow_cursor = true,
      -- Only recompiles what the viewport needs; this is what keeps a very long
      -- append-only log fast. Stated explicitly so it doesn't get "tidied away".
      partial_rendering = true,
    },
  },

  -- Unicode maths and headings in the buffer itself, for reading back old entries
  -- without opening the preview. render-markdown.nvim already owns markdown, and
  -- the two fight over conceals, so each is scoped to one filetype.
  {
    "OXY2DEV/markview.nvim",
    ft = { "typst" },
    opts = {
      preview = {
        enable = true,
        filetypes = { "typst" },
      },
      typst = { enable = true },
    },
  },

  -- LazyVim swaps foldexpr to vim.lsp.foldexpr() on its own once a server
  -- advertises textDocument/foldingRange, which tinymist does, so headings fold
  -- without further setup. Only the fold level needs changing, since LazyVim
  -- sets foldlevel=99 globally and a long log wants to open collapsed.
  --
  -- Level 1 rather than 0: tinymist nests every `==` entry inside the document's
  -- `=` title, so 0 hides the whole file behind one fold. 1 leaves the title
  -- open and closes each dated entry, which is the scannable index of dates.
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
          vim.wo.foldlevel = 1
        end,
      })
    end,
  },
}
