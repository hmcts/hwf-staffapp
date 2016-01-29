SPECS_PATH = ./tests/nightwatch/specs

ifdef spec
	specific_test = -t ${SPECS_PATH}/${spec}.js
endif

ifdef browser
	environment = --env ${browser}
endif

# running tests on local env
test:
	./nightwatch -c tests/nightwatch/local.json ${environment} ${specific_test}
test-chrome:
	./nightwatch -c tests/nightwatch/local.json --env chrome ${specific_test}
test-firefox:
	./nightwatch -c tests/nightwatch/local.json --env firefox ${specific_test}
