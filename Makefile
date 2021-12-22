install:
	install -m 755 ./btb.sh /usr/bin/btb.sh

uninstall:
	rm /usr/bin/btb.sh

reinstall:
	install -m 755 ./btb.sh /usr/bin/btb.sh