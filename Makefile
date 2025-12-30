SHELL := /bin/bash

.PHONY: jar icon app dmg workflow install-app

jar:
	./scripts/fetch-latest-jar.sh

license:
	./scripts/fetch-hmcl-license.sh

icon:
	./scripts/make-icon.sh ./icon/HMCL.png

app:
	./scripts/make-app.sh --jar ./.cache/HMCL-latest.jar --icon ./.output/HMCL.icns

dmg:
	./scripts/make-dmg.sh --app ./.output/HMCL.app --out ./.output/HMCL.dmg --volname HMCL

workflow:
	./scripts/workflow.sh

install-app:
	./scripts/install-app.sh
