declare-option str kakoune_persist_db "%val{config}/plugins/kakoune-persist/db"
declare-option -hidden str this_path "%val{config}/plugins/kakoune-persist/"
declare-option str kakoune_persist_current_val

provide-module kakoune-persist %^
  define-command save_to_db -params 3 -docstring %{
    -1: category
    -2: key
    -3: value
  } %{
    lua %opt{this_path} %opt{dashboard_db} %arg{1} %arg{2} %arg{3} %{
      addpackagepath(arg[1])
      local persist = require "persist"
      persist(arg[2]).save(arg[3], arg[4], arg[5])
    }
  }

  define-command load_to_option -params 2..3 -docstring %{
    -1: category
    -2: key
    -3: option
  } %{
    lua %opt{this_path} %opt{dashboard_db} %arg{1} %arg{2} %arg{3} %{
      addpackagepath(arg[1])
      local persist = require "persist"
      local val = persist(arg[2]).load(arg[3], arg[4])
      kak.set_option(arg[5] or "kakoune_persist_current_val", val)
    }
  }
^
