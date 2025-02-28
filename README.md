# micro.hs

micro.hs is a collection of utilities & libraries for Obsidian, modeled losely on [mini.nvim](https://github.com/echasnovski/mini.nvim).

## Fennel

If you don't already use Fennel there will be an extra step needed to make use of micro.hs. In the future I'll look into providing the code here as pre-compiled Lua code, but that is more complicated to distribute so no promises.

### Embedding Fennel

Fennel is a light syntax layer on top of Lua that fixes some of the sharp edges of the language. Fennel has no runtime and is easy and transparent to embed.

1. Download the Fennel script by following the first step [here](https://fennel-lang.org/setup#downloading-the-fennel-script)
2. Move the script into your hammerspoon root (e.g., `~/.hammerspoon`)
    - I locate mine at `~/.hammerspoon/fennel/fennel.lua`
3. "Install" Fennel in `init.lua`:

```clojure
;; setup path.searchers to recognize and handle .fnl files
require("fennel/fennel").install()
;; fennel files can now be required just like Lua files, e.g.:
require("a-fennel-file") ;; no '.fnl' needed
```

## Todo

- [ ] explain installing all of `micro.hs`, including symlinking `micro.hs/fnl/micro` as `micro` in the Hammerspoon root, so imports like `require(micro.<module>)` work
- [ ] explain converting the Fennel example configurations to Lua syntax if people want to configure it that way
