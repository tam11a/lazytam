# lazytam dev tasks. Tests need bash and Python 3.11+; `arch` needs Docker.
SH := install.sh bin/lazytam lib/common.sh modules/*/setup.sh defaults/shell/rc.sh tests/*.sh

.PHONY: test unit cli lint arch readme

test: unit cli

unit:
	python3 -m unittest discover -s tests

cli:
	bash tests/cli.sh

lint:
	@for f in $(SH); do bash -n "$$f" || exit 1; done; echo "bash -n: ok"
	@if command -v shellcheck >/dev/null; then shellcheck -s bash -x -S warning $(SH); \
	elif command -v docker >/dev/null; then docker run --rm -v "$$PWD:/mnt" -w /mnt koalaman/shellcheck:stable -s bash -x -S warning $(SH); \
	else echo "shellcheck not found (install it or Docker); skipped"; fi
	@echo "shellcheck: ok"

arch:
	bash tests/arch-install.sh

readme:
	python3 docs/assets/build.py
