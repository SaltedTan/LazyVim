-- Rocq (Coq) proofs with Coqtail: step through a proof and see the goals in a split.
-- Rocq comes from the opam switch "sf" (Software Foundations; see
-- ~/code/software-foundations/README.md), so Neovim needs no opam environment.
--
-- Keys, in normal mode in a .v buffer (LazyVim's local leader is "\"; :h coqtail):
--   \c start Rocq for this file     \q stop
--   \j step forward                 \k step back        (both take a count)
--      then j / k keep stepping, as ; repeats f; any other key leaves step mode
--   \l check up to the cursor line  \T rewind to the top
--   \G cursor to the end of the checked region          \E cursor to the error
--   \r reopen the goal and info panels
--   \h Check, \a About, \p Print, \s Search the term under the cursor

-- Step mode: after \j or \k, a bare j or k (with an optional count) steps again. The first
-- key that is not j, k or a digit leaves the mode and does what it normally does.
local step_ns = vim.api.nvim_create_namespace("rocq_step_mode")
local stepping = nil -- buffer in step mode, if any

local function leave_step_mode()
  local buf = stepping
  if not buf then
    return
  end
  stepping = nil
  vim.on_key(nil, step_ns)
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.keymap.del, "n", "j", { buffer = buf })
    pcall(vim.keymap.del, "n", "k", { buffer = buf })
  end
  vim.api.nvim_echo({}, false, {})
end

local function step(cmd)
  return function()
    vim.cmd(vim.v.count1 .. cmd)
  end
end

local function enter_step_mode(buf)
  if stepping == buf then
    return
  end
  leave_step_mode()
  stepping = buf
  vim.keymap.set("n", "j", step("RocqNext"), { buffer = buf, desc = "Rocq: step forward" })
  vim.keymap.set("n", "k", step("RocqUndo"), { buffer = buf, desc = "Rocq: step back" })
  vim.api.nvim_echo({ { "-- STEP --  j/k step, any other key leaves", "ModeMsg" } }, false, {})
  -- Runs after mappings are resolved; `typed` is what was typed (empty for keys a mapping
  -- produced). Leave on the first typed key that is not j, k or part of a count.
  vim.on_key(function(_, typed)
    if typed == "" or typed:match("^[jk0-9]+$") then
      return
    end
    vim.schedule(leave_step_mode)
  end, step_ns)
end

local function step_and_enter(cmd)
  return function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd(vim.v.count1 .. cmd)
    -- After this mapping's own keys have gone through on_key.
    vim.schedule(function()
      enter_step_mode(buf)
    end)
  end
end

return {
  {
    "whonore/Coqtail",
    -- Not lazy-loaded: its ftdetect is what marks *.v as Rocq rather than Verilog.
    lazy = false,
    init = function()
      vim.g.coqtail_coq_path = vim.fn.expand("~/.opam/sf/bin")
      -- The default prefix, <leader>c, is LazyVim's "code" group.
      vim.g.coqtail_map_prefix = "<localleader>"
      -- No insert-mode mappings: with "\" as the prefix they would catch Rocq notation
      -- such as /\, \/ and PLF's \in.
      vim.g.coqtail_noimap = 1
      -- Highlight what each step changed in the goals.
      vim.g.coqtail_auto_set_proof_diffs = "on"
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "coq",
        group = vim.api.nvim_create_augroup("rocq_step_mode", { clear = true }),
        callback = function(ev)
          -- Replace Coqtail's \j and \k with versions that also enter step mode.
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(ev.buf) then
              return
            end
            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "<localleader>j", step_and_enter("RocqNext"),
              vim.tbl_extend("force", opts, { desc = "Rocq: step forward (then j/k)" }))
            vim.keymap.set("n", "<localleader>k", step_and_enter("RocqUndo"),
              vim.tbl_extend("force", opts, { desc = "Rocq: step back (then j/k)" }))
          end)
        end,
      })
    end,
  },
}
