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

    def __cinit__(self):
        """Initializes class with
        default options.
        """

    def __init__(self, dictionary="en"):
        self._dictionary=_s(dictionary)

    @property
    def version(self):
        return _u(linkgrammar_get_version())

    @property
    def dictionary(self):
        return _u(self._dictionary)





cdef simple_test():
    print (linkgrammar_get_version())
