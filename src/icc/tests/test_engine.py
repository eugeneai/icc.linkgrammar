import icc.linkgrammar as lg

class test_engine:
    def setUp(self):
        """
        """
        self.p=lg.LinkGrammar("ru")

    def tearDown(self):
        del self.p

    def test_version(self):
        """
        """
        assert self.p.version.startswith("link-grammar")

    def test_dictionary(self):
        """
        """
        assert self.p.dictionary=="ru"
