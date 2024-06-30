.PHONY: install uninstall commit

install:
	git checkout src/
	cp -r counter-original/src/. src/
	npx elm-review --fix-all

uninstall:
	cp -r counter-original/src/. src/

commit:
	cp -r counter-original/src/. src/
	git checkout vendor/magic-link/Config.elm
	git commit -a
