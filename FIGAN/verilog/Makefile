MODULE ?= and_32

build:
	mkdir -p build
	iverilog -o build/$(MODULE)_tb tb/$(MODULE)_tb.v rtl/*.v

run: build
	vvp build/$(MODULE)_tb

wave: run
	gtkwave build/$(MODULE)_tb.vcd

clean:
	rm -f build/*.vcd build/*_tb

.PHONY: build run wave clean