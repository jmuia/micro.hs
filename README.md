                                            .--.          ...                                       
                                           -+++-         -+++.                                      
                                          .++++.        .++++                                       
                                          -+++-         -+++.                                       
                                         .++++.        .++++.                                       
                                         -++++         -+++-                                        
                                        .++++.        .++++.                                        
                                        -++++         -+++-                                         
                                        ++++-        .++++.  .--                                    
                                       .++++.        -++++   -+-                                    
                                       +++++-      .+++++-  .++.                                    
                                      .++++++-...-+++-++++..++.                                     
                                      -+++--+++++--.  .-++++-.                                      
                                     .++++.                                                         
                                     -+++-                                                          
                                    .++++.                                                          
                                    -+++-                                                           
                                    ++++.                                                           
                                    .--.                                                            

# micro.hs

micro.hs is a collection of utilities & libraries for Hammerspoon, modeled loosely on [mini.nvim](https://github.com/echasnovski/mini.nvim).

## Modules

| name | description |
| --- | --- |
| [chords](fnl/micro/chords/README.md) | Provides key chords to organize hammerspoon functionality as an alternative to traditional key bindings, along with a visual interface for discoverability. |

There are other files under `fnl/micro` that are incomplete (or even empty). They're ideas for future modules.

## Fennel

If you don't already use Fennel there will be an extra step needed to make use of micro.hs. In the future I'll look into providing the code here as pre-compiled Lua code, but that is more complicated to distribute so no promises.

### Embedding Fennel

Fennel is a light syntax layer on top of Lua that fixes some of the sharp edges of the language. Fennel has no runtime and is easy and transparent to embed.

1. Download the Fennel script by following the first step [here](https://fennel-lang.org/setup#downloading-the-fennel-script)
2. Move the script into your hammerspoon root (`~/.hammerspoon` in this example)
    - I locate mine at `~/.hammerspoon/fennel/fennel.lua`
3. "Install" Fennel in `init.lua`:

```clojure
;; `require` the fennel script using the normal Lua require rules.
;; Call `.install()` to configure path.searchers to recognize and handle .fnl files.
;; E.g.:

;; require("fennel").install() ;; if located at ~/.hammerspoon/fennel.lua
require("fennel/fennel").install() ;; if located at ~/.hammerspoon/fennel/fennel.lua

;; fennel files can now be required just like Lua files, e.g.:
require("a-fennel-file") ;; no '.fnl' needed
```

## Installing all of `micro.hs`

The gist is that you want to checkout the repo somewhere that retains its structure as a git repo (so you can continue to pull updates) while making the code in `micro.hs/fnl/micro` available for your Hammerspoon config to import.

### Linking the modules

The second step can be accomplished by using a symlink from your Hammerspoon root, e.g.:

```bash
$ ln -s <micro.hs-checkout-location>/fnl/micro <hammerspoon-root>/micro
```

This makes all of the `micro.hs` modules available as `micro.<module-name>`, e.g., `micro.chords`.

You can add `micro` to your `.gitignore`, depending on your setup

### Checking out the repo

This will come down to how you have set up your Hammerspoon config with version control.

For example, in [my config](https://git.corp.stripe.com/jshumway/hammerspoon) I added `micro.hs` as a submodule, so that I could version my configuration as a separate repository without interfering with the `micro.hs` repository.

Some people like to checkout repositories into a `./Spoons` directory that isn't checked in to VCS, which is also reasonable.

## Todo

- [X] explain installing all of `micro.hs`, including symlinking `micro.hs/fnl/micro` as `micro` in the Hammerspoon root, so imports like `require(micro.<module>)` work
- [ ] explain converting the Fennel example configurations to Lua syntax if people want to configure it that way
