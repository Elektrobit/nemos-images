buildroot = /

install:
	install -d -m 755 ${buildroot}usr/share/kiwi/nautilos
	cp -a test-image-embedded-lunar ${buildroot}usr/share/kiwi/nautilos
