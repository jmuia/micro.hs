FNL_SRC := $(shell find fnl -name '*.fnl')
LUA_OUT := $(FNL_SRC:fnl/%.fnl=lua/%.lua)

.PHONY: build clean check

build: $(LUA_OUT)

lua/%.lua: fnl/%.fnl
	@mkdir -p $(dir $@)
	fennel --compile $< > $@

clean:
	rm -rf lua/

check: build
	@git diff --exit-code lua/ || (echo "Compiled Lua is out of date. Run 'make build' and commit the result." && exit 1)
