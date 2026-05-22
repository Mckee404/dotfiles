return {
  settings = {
    python = {
      analysis = {
        ignore = { "*" },
      },
    },
  },
  handlers = {
    ["$/progress"] = function() end,
  },
}
