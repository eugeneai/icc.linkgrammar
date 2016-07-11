# Example package with a console entry point
from __future__ import print_function
import cplinkgrammar as lg


def main():
    print ("Hello World")
    g=lg.LinkGrammar("ru")
    print (g.version)
    print (g.dictionary)


if __name__=="__main__":
    main()
    quit()
