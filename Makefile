.PHONY: install uninstall commit

install:
	git checkout src/
	cp -r counter-original/src/. src/
	cp vendor-secret/Env.elm src/
	npx elm-review --fix-all

uninstall:
	cp vendor-open/Env.elm src/
	cp -r counter-original/src/. src/

commit:
	cp -r counter-original/src/. src/
	cp vendor-open/Env.elm src/
	git commit -a

