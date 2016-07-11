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

cdef char * _s(o):
    return PyUnicode_AsUTF8(o)

cdef _u(const char * s):
    return PyUnicode_FromString(s)

cdef class LinkGrammar:
    """Represents link grammar.
    """
    cdef char * _dictionary
    cdef Sentence _sent
    cdef Parse_Options _opts;
    cdef Dictionary _dict;
    cdef Linkage _linkage;

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

    def diagram(self, num=None, bool display_walls=1, size_t screen_width=80):
        cdef char * s
        if num!=None:
            self.linkage(num)
        s=linkage_print_diagram(self._linkage, display_walls, screen_width)
        u=_u(s)
        linkage_free_diagram(s)
        return u

    property linkage_limit:
        def __set__(self, int lim):
            parse_options_set_linkage_limit(self._opts, lim)
        def __get__(self):
            return parse_options_get_linkage_limit(self._opts)

    property max_parse_time:
        def __set__(self, int time):
            parse_options_set_max_parse_time(self._opts, time)
        def __get__(self):
            return parse_options_get_max_parse_time(self._opts)
