N=httpd_svirt

all: $(N).pp

$(N).pp: $(N).mod
	semodule_package -o $(N).pp -m $(N).mod
$(N).mod: $(N).te
	checkmodule -M -m -o $(N).mod $(N).te
.PHONY: all clean
clean:
	rm -f $(N).mod
	rm -f $(N).pp

install:
	semodule -i $(N).pp
uninstall:
	semodule -r $(N).pp

