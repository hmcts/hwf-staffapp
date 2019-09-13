SPECS_PATH = ./tests/nightwatch/specs

ifdef spec
	specific_test = -t ${SPECS_PATH}/${spec}.js
endif

ifdef browser
	environment = --env ${browser}
endif
