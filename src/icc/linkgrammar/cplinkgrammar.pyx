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

class LinkageItem:
    def __init__(self, engine, index):
        self.engine=engine
        self.index=index

    def __del__(self):
        self.engine.release_linkage(self.index)
        del self.engine

cdef class LinkGrammar:
    """Represents link grammar.
    """
    cdef char * _dictionary
    cdef Sentence _sent
    cdef Parse_Options _opts;
    cdef Dictionary _dict;
    cdef int _idx;

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
        self._idx=-1;

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
        if self._sent!=NULL:
            sentence_delete(self._sent)
            self._sent=NULL

    cdef dict_make(self):
        if self._dict==NULL:
            self._dict=dictionary_create_lang(self._dictionary)
            if self._dict==NULL:
                raise RuntimeError("cannot create a dictionary")

    cdef dict_delete(self):
        if self._dict!=NULL:
            dictionary_delete(self._dict)
            self._dict=NULL

    def __dealloc__(self):
        #print ("----- Deallocation!!!! ----")
        self.sent_delete()
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

    def linkage(self, LinkIdx num):
        self.check_sent()
        nl=self.num_linkages
        if nl==0:
            return None
        if <int> num<0 or num>nl:
            raise IndexError("wrong linkage index")
        if self._idx!=-1:
            raise RuntimeError("release previously used linkage")
        self._idx = <int> num
        return LinkageItem(self, num)

    def release_linkage(self, LinkageIdx num):
        if self._idx == <int> num:
            self._idx = -1
        else:
            raise ValueError("wrong linkage release")

cdef simple_test():
    print (linkgrammar_get_version())
