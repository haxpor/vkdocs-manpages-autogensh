.PHONY: all clean install purge

# forward target API version to internal script
SPECV=

all:
	@if [ -z $(SPECV) ]; then \
		echo "Target build is latest spec."; \
		./build.sh; \
	else \
		echo "Target build spec is $(SPECV)"; \
		./build.sh $(SPECV); \
	fi;

clean:
	# note: execute bash script in Makefile (remember to use \ and ; at the end)
	@if [ -f Vulkan-Docs/Makefile ]; then \
		cd Vulkan-Docs; \
		make clean_onlymanpages; \
	fi;

install:
	@if [ -d Vulkan-Docs/out/man ]; then \
		cd Vulkan-Docs/out/man; \
		cp -p * /usr/local/man/man3/; \
		echo "Installed successfully"; \
	else \
		echo "Do nothing as there is no generated manpages"; \
	fi;

purge:
	rm -rf Vulkan-Docs
