from nose.tools import *

import icc.linkgrammar as lg
parser=lg.LinkGrammar("ru")

class test_engine:
    def setUp(self):
        """
        """
        self.p=parser

    def tearDown(self):
        self.p.clean()
        del self.p

    def test_version(self):
        assert self.p.version.startswith("link-grammar")

    def test_dictionary(self):
        assert self.p.dictionary=="ru"

    def test_parsing_simple_sentence(self):
        assert self.p.parse("Я иду по Москве.")

    def test_parsing_simple_sentence2(self):
        assert self.p.parse("Я иду по Иркутску.")

    def test_num_linkages(self):
        self.p.parse("Я живу.")
        assert self.p.num_linkages>0

    def test_num_linkages(self):
        self.p.parse("Я иду по улице.")
        assert self.p.num_linkages>0

    def test_num_valid_linkages(self):
        self.p.parse("Я иду по улице.")
        assert self.p.num_valid>0

    @raises(IndexError)
    def test_linkage_access1(self):
        self.p.parse("Я иду по улице.")
        self.p.linkage(65536)

    @raises(OverflowError)
    def test_linkage_access2(self):
        self.p.parse("Я иду по улице.")
        self.p.linkage(-5)

    def test_linkage_access3(self):
        self.p.parse("Я иду по улице.")
        rc=self.p.linkage(0)
        print ("RC:", rc)
        assert rc

    def test_linkage_access_multi(self):
        self.p.parse("Я иду по улице.")
        assert self.p.linkage(0)
        assert self.p.linkage(1)

    def test_linkage_print_diagram(self):
        self.p.parse("Я иду по улице.")
        assert self.p.linkage(0)
        diag=self.p.diagram()
        print (diag)
        assert diag

    def text_linkage_set_option_parse_time(self):
        self.p.parse("Я иду по улице.")
        self.p.parse_time=10
        assert self.p.linkage(0)
        assert self.p.parse_time==10

    def text_linkage_set_option_max_linkages(self):
        self.p.parse("Я иду по улице.")
        self.p.max_linkages=1
        assert self.p.linkage(0)
        assert self.p.max_linkages==1


    def text_linkage_set_option_verbosity(self):
        self.p.parse("Я иду по улице.")
        self.p.verbosity=1
        assert self.p.linkage(0)
        assert self.p.verbosity==1
