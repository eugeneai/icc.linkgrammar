.PHONY: env dev develop install test edit \
	py pot init-ru update-ru comp-cat \
	upd-cat setup test setup-requs tests \
	run-tests gdb-test clean

TOP_DIR="/home/eugeneai/Development/codes/NLP/link-grammar"

LPYTHON=python3
V=$(PWD)/../$(LPYTHON)
VB=$(V)/bin
PYTHON=$(VB)/$(LPYTHON)
ROOT=$(PWD)
#INI=icc.linkgrammar
#LCAT=src/icc/linkgrammar/locale/

LG_DIR="link-grammar"
LG_LIB_DIR=$(TOP_DIR)/$(LG_DIR)/.libs
LG_HEADERS=$(TOP_DIR)/

env:
	[ -d $(V) ] || virtualenv  $(V)
	$(VB)/easy_install --upgrade pip

pre-dev:env #dev-....
	$(VB)/easy_install pip setuptools

setup:
	$(PYTHON) setup.py build_ext -L$(LG_LIB_DIR) -R$(LG_LIB_DIR) -I$(LG_HEADERS)
	$(PYTHON) setup.py develop

dev:	pre-dev setup-requs setup # upd-cat

develop: dev

install: env comp-cat
	$(PYTHON) setup.py install

edit:
	cd src && emacs

setup-requs: requirements.txt
	pip install -r requirements.txt

run-tests:
	nosetests -w src/icc/tests

tests:	run-tests

test:	setup run-tests

gdb-test: setup
	gdb --args $(PYTHON) $(VB)/nosetests -w src/icc/tests

py:
	$(PYTHON)
pot:
	mkdir -p $(LCAT)
	$(VB)/pot-create src -o $(LCAT)/messages.pot || echo "Someting unusual with pot."

init-ru:
	$(PYTHON) setup.py init_catalog -l ru -i $(LCAT)/messages.pot \
                         -d $(LCAT)

update-ru:
	$(PYTHON) setup.py update_catalog -l ru -i $(LCAT)/messages.pot \
                            -d $(LCAT)

comp-cat:
	$(PYTHON) setup.py compile_catalog -d $(LCAT)

upd-cat: pot update-ru comp-cat

clean:
	$(PYTHON) setup.py clean
	

#adjust-ini:
#	sed 's/HOME/\/home\/$(USER)/' icc.cellula.ini.in > icc.cellula.ini
