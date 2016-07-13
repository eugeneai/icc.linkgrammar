# cython: language_level=3
#

cdef extern from "Python.h":
    object PyUnicode_FromStringAndSize(char *, int)
    object PyUnicode_FromString(char *)
    char *PyUnicode_AsUTF8(object o)

    object PyInt_FromLong(long ival)
    long PyInt_AsLong(object io)

    object PyList_New(int len)
    int PyList_SetItem(object list, int index, object item)

    void Py_INCREF(object o)

    object PyObject_GetAttrString(object o, char *attr_name)
    object PyTuple_New(int len)
    int PyTuple_SetItem(object p, int pos, object o)
    object PyObject_Call(object callable_object, object args, object kw)
    object PyObject_CallObject(object callable_object, object args)
    int PyObject_SetAttrString(object o, char *attr_name, object v)

cdef extern from "signal.h":                # Used for debugging C seaside.
    ctypedef unsigned int signal_t
    void c_raise "raise" (signal_t signal)

cdef enum:
    SIGINT = 2

cdef char * _s(o):
    return PyUnicode_AsUTF8(o)

cdef _u(const char * s):
    if s!=NULL:
        return PyUnicode_FromString(s)
    else:
        return u"<NULL>"

cdef class LinkGrammar:
    """Represents link grammar.
    """
    cdef char * _dictionary
    cdef Sentence _sent
    cdef Parse_Options _opts;
    cdef Dictionary _dict;
    cdef Linkage _linkage;
    cdef bool _panic_mode;

    def __cinit__(self):
        """Initializes class with
        default options.
        """
        self._dictionary=NULL
        self._sent=NULL
        self._opts=parse_options_create()
        if self._opts==NULL:
            raise RuntimeError("cannot create options")
        self._dict=NULL
        self._linkage=NULL;
        self._panic_mode=0;

    def __init__(self, dictionary="en"):
        self._dictionary=_s(dictionary)
        # self.dict_make()

    @property
    def version(self):
        return _u(linkgrammar_get_version())

    @property
    def dictionary(self):
        return _u(self._dictionary)

    def parse(self, sentence):
        self.dict_make()
        self.sent_delete()
        s=_s(sentence)
        sent = self._sent = sentence_create(s, self._dict)
        if sent == NULL:
            raise RuntimeError("cannot create sentence structure")
        sentence_parse(sent, self._opts)
        return 1

    cdef sent_delete(self):
        self.release_linkage()
        if self._sent!=NULL:
            sentence_delete(self._sent)
            self._sent=NULL

    cdef dict_make(self):
        if self._dict==NULL:
            self._dict=dictionary_create_lang(self._dictionary)
            if self._dict==NULL:
                raise RuntimeError("cannot create a dictionary")

    cdef dict_delete(self):
        self.sent_delete()
        if self._dict!=NULL:
            dictionary_delete(self._dict)
            self._dict=NULL

    def clean(self):
        self.sent_delete()
        # Reset options to default
        parse_options_delete(self._opts)
        self._opts=parse_options_create()

    def __dealloc__(self):
        self.dict_delete()
        parse_options_delete(self._opts)
        self._opts=NULL

    cdef check_sent(self):
        if self._sent==NULL:
            raise RuntimeError("run parse at first")

    @property
    def num_linkages(self):
        self.check_sent()
        return sentence_num_linkages_found(self._sent)

    @property
    def num_valid(self):
        self.check_sent()
        return sentence_num_valid_linkages(self._sent)

    cdef bool linkage_prep(self, LinkageIdx num) except *:
        self.check_sent()
        if self.num_linkages==0:
            return 0
        self.check_idx(num)
        self.release_linkage()
        self._linkage=linkage_create(num, self._sent, self._opts)
        return 1

    cdef check_idx(self, LinkageIdx num):
        nl=self.num_linkages
        if <int> num<0 or num>nl:
            raise IndexError("wrong linkage index")

    cdef release_linkage(self):
        if self._linkage != NULL:
            linkage_delete(self._linkage)
            self._linkage=NULL

    def linkage(self, LinkageIdx num, raise_exception=False):
        rc = self.linkage_prep(num)
        if not rc and raise_exception:
            raise RuntimeError("cannot create linkage")
        return rc

    cdef void _check_linkage(self) except *:
        if self._linkage==NULL:
            raise RuntimeError("create linkage first or set the first parameter "\
                               "to a linkage number")

    def check_linkage(self, num=None):
        if type(num) == int:
            self.linkage(num)
        self._check_linkage()

    def diagram(self, num=None, bool display_walls=1, size_t screen_width=32767):
        cdef char * s
        self.check_linkage(num)
        s=linkage_print_diagram(self._linkage, display_walls, screen_width)
        u=_u(s)
        linkage_free_diagram(s)
        return u

    def pp_msgs(self, num=None):
        cdef char * s
        self.check_linkage(num)
        s=linkage_print_pp_msgs(self._linkage)
        u=_u(s)
        linkage_free_pp_msgs(s)
        return u

    property linkage_limit:
        def __set__(self, int value):
            parse_options_set_linkage_limit(self._opts, value)
        def __get__(self):
            return parse_options_get_linkage_limit(self._opts)

    property max_parse_time:
        def __set__(self, int value):
            parse_options_set_max_parse_time(self._opts, value)
        def __get__(self):
            return parse_options_get_max_parse_time(self._opts)

    property verbosity:
        def __set__(self, int value):
            parse_options_set_verbosity(self._opts, value)
        def __get__(self):
            return parse_options_get_verbosity(self._opts)

    property debug:
        def __set__(self, name ):
            parse_options_set_debug(self._opts, _s(name))
        def __get__(self):
            return _u(parse_options_get_debug(self._opts))

    property test:
        def __set__(self, name ):
            parse_options_set_test(self._opts, _s(name))
        def __get__(self):
            return _u(parse_options_get_test(self._opts))


    property disjunct_cost:
        def __set__(self, double value):
            parse_options_set_disjunct_cost(self._opts, value)
        def __get__(self):
            return parse_options_get_disjunct_cost(self._opts)

    property min_null_count:
        def __set__(self, int value):
            parse_options_set_min_null_count(self._opts, value)
        def __get__(self):
            return parse_options_get_min_null_count(self._opts)

    property max_null_count:
        def __set__(self, int value):
            parse_options_set_max_null_count(self._opts, value)
        def __get__(self):
            return parse_options_get_max_null_count(self._opts)

    property islands_ok:
        def __set__(self, bool value):
            parse_options_set_islands_ok(self._opts, value)
        def __get__(self):
            return parse_options_get_islands_ok(self._opts)

    property use_sat_parse:
        def __set__(self, bool value):
            parse_options_set_use_sat_parser(self._opts, value)
        def __get__(self):
            return parse_options_get_use_sat_parser(self._opts)

    property use_viterbi:
        def __set__(self, bool value):
            parse_options_set_use_viterbi(self._opts, value)
        def __get__(self):
            return parse_options_get_use_viterbi(self._opts)

    property spell_guess:
        def __set__(self, int value):
            parse_options_set_spell_guess(self._opts, value)
        def __get__(self):
            return parse_options_get_spell_guess(self._opts)

    property short_length:
        def __set__(self, int value):
            parse_options_set_short_length(self._opts, value)
        def __get__(self):
            return parse_options_get_short_length(self._opts)

    property max_memory:
        def __set__(self, int value):
            parse_options_set_max_memory(self._opts, value)
        def __get__(self):
            return parse_options_get_max_memory(self._opts)

    property timer_expired:
        def __get__(self):
            return parse_options_timer_expired(self._opts)

    property memory_exhausted:
        def __get__(self):
            return parse_options_memory_exhausted(self._opts)

    property resources_exhausted:
        def __get__(self):
            return parse_options_resources_exhausted(self._opts)

    property use_cluster_disjuncts:
        def __set__(self, bool value):
            parse_options_set_use_cluster_disjuncts(self._opts, value)
        def __get__(self):
            return parse_options_get_use_cluster_disjuncts(self._opts)

    property all_short_connectors:
        def __set__(self, bool value):
            parse_options_set_all_short_connectors(self._opts, value)
        def __get__(self):
            return parse_options_get_all_short_connectors(self._opts)

    property repeatable_rand:
        def __set__(self, bool value):
            parse_options_set_repeatable_rand(self._opts, value)
        def __get__(self):
            return parse_options_get_repeatable_rand(self._opts)

    property panic_mode:
        def __set__(self, bool value):
            self._panic_mode=value
        def __get__(self):
            return self._panic_mode

    def reset_resources(self):
        parse_options_reset_resources(self._opts)

    def setup_abiword_main(self):
        self.disjunct_cost=2.0
        self.min_null_count=0
        self.max_null_count=0
        self.islands_ok=0
        self.panic_mode=1
        self.max_parse_time=1
        self.reset_resources()

    def setup_abiword_soft(self):

        self.disjunct_cost=2.0
        self.min_null_count=1
        #
        # We do not know the length of a sentence.
        # parse_options_set_max_null_count(m_Opts, sentence_length(sent));
        #
        self.max_null_count=40
        self.islands_ok=1
        self.panic_mode=0
        self.max_parse_time=1
        self.reset_resources()
