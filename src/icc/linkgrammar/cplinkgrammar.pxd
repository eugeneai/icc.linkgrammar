# cython: language_level=3
# Declaration of link-grammar functions.
cdef extern from "link-grammar/link-includes.h":
    ctypedef struct Dictionary_s :
        pass
    ctypedef Dictionary_s * Dictionary

    ctypedef unsigned int bool
    ctypedef unsigned int size_t

    const char * linkgrammar_get_version();
    const char * linkgrammar_get_dict_version(Dictionary);

    # **********************************************************************
    # *
    # * Functions to manipulate Dictionaries
    # *
    # **********************************************************************

    Dictionary dictionary_create_lang(const char * lang);
    Dictionary dictionary_create_default_lang();
    const char * dictionary_get_lang(Dictionary);

    void dictionary_delete(Dictionary);

    void dictionary_set_data_dir(const char * path);
    char * dictionary_get_data_dir();

    # **********************************************************************
    # *
    # * Functions to manipulate Parse Options
    # *
    # **********************************************************************

    # typedef enum
    # {
    #     VDAL=1, /* Sort by Violations, Disjunct cost, Link cost */
    #     CORPUS, /* Sort by Corpus cost */
    # } Cost_Model_type;

    ctypedef unsigned int Cost_Model_type

    ctypedef struct Parse_Options_s:
        pass
    ctypedef Parse_Options_s * Parse_Options

    Parse_Options parse_options_create();
    int parse_options_delete(Parse_Options opts);
    void parse_options_set_verbosity(Parse_Options opts, int verbosity);
    int parse_options_get_verbosity(Parse_Options opts);
    void parse_options_set_debug(Parse_Options opts, const char * debug);
    char * parse_options_get_debug(Parse_Options opts);
    void parse_options_set_test(Parse_Options opts, const char * test);
    char * parse_options_get_test(Parse_Options opts);
    void parse_options_set_linkage_limit(Parse_Options opts, int linkage_limit);
    int parse_options_get_linkage_limit(Parse_Options opts);
    void parse_options_set_disjunct_cost(Parse_Options opts, double disjunct_cost);
    double parse_options_get_disjunct_cost(Parse_Options opts);
    void parse_options_set_min_null_count(Parse_Options opts, int null_count);
    int parse_options_get_min_null_count(Parse_Options opts);
    void parse_options_set_max_null_count(Parse_Options opts, int null_count);
    int parse_options_get_max_null_count(Parse_Options opts);
    void parse_options_set_islands_ok(Parse_Options opts, bool islands_ok);
    bool parse_options_get_islands_ok(Parse_Options opts);
    void parse_options_set_spell_guess(Parse_Options opts, int spell_guess);
    int parse_options_get_spell_guess(Parse_Options opts);
    void parse_options_set_short_length(Parse_Options opts, int short_length);
    int parse_options_get_short_length(Parse_Options opts);
    void parse_options_set_max_memory(Parse_Options  opts, int mem);
    int parse_options_get_max_memory(Parse_Options opts);
    void parse_options_set_max_parse_time(Parse_Options  opts, int secs);
    int parse_options_get_max_parse_time(Parse_Options opts);
    void parse_options_set_cost_model_type(Parse_Options opts, Cost_Model_type cm);
    Cost_Model_type parse_options_get_cost_model_type(Parse_Options opts);
    void parse_options_set_use_sat_parser(Parse_Options opts, bool use_sat_solver);
    bool parse_options_get_use_sat_parser(Parse_Options opts);
    void parse_options_set_use_viterbi(Parse_Options opts, bool use_viterbi);
    bool parse_options_get_use_viterbi(Parse_Options opts);
    bool parse_options_timer_expired(Parse_Options opts);
    bool parse_options_memory_exhausted(Parse_Options opts);
    bool parse_options_resources_exhausted(Parse_Options opts);
    void parse_options_set_use_cluster_disjuncts(Parse_Options opts, bool val);
    bool parse_options_get_use_cluster_disjuncts(Parse_Options opts);
    void parse_options_set_all_short_connectors(Parse_Options opts, bool val);
    bool parse_options_get_all_short_connectors(Parse_Options opts);
    void parse_options_set_repeatable_rand(Parse_Options opts, bool val);
    bool parse_options_get_repeatable_rand(Parse_Options opts);
    void parse_options_reset_resources(Parse_Options opts);


    # **********************************************************************
    # *
    # * The following Parse_Options functions do not directly affect the
    # * operation of the parser, but they can be useful for organizing the
    # * search, or displaying the results.  They were included as switches for
    # * convenience in implementing the "standard" version of the link parser
    # * using the API.
    # *
    # ***********************************************************************

    # typedef enum
    # {
    #     NO_DISPLAY = 0,        /** Display is disabled */
    #     MULTILINE = 1,         /** multi-line, indented display */
    #     BRACKET_TREE = 2,      /** single-line, bracketed tree */
    #     SINGLE_LINE = 3,       /** single line, round parenthesis */
    #    MAX_STYLES = 3         /* this must always be last, largest */
    # } ConstituentDisplayStyle;

    ctypedef unsigned int ConstituentDisplayStyle

    void parse_options_set_display_morphology(Parse_Options opts, int val);
    int parse_options_get_display_morphology(Parse_Options opts);

    # **********************************************************************
    # *
    # * Functions to manipulate Sentences
    # *
    # **********************************************************************

    ctypedef struct Sentence_s:
        pass
    ctypedef Sentence_s * Sentence

    ctypedef size_t LinkageIdx

    Sentence sentence_create(const char *input_string, Dictionary dict);
    void sentence_delete(Sentence sent);
    int sentence_split(Sentence sent, Parse_Options opts);
    int sentence_parse(Sentence sent, Parse_Options opts);
    int sentence_length(Sentence sent);
    int sentence_null_count(Sentence sent);
    int sentence_num_linkages_found(Sentence sent);
    int sentence_num_valid_linkages(Sentence sent);
    int sentence_num_linkages_post_processed(Sentence sent);
    int sentence_num_violations(Sentence sent, LinkageIdx linkage_num);
    double sentence_disjunct_cost(Sentence sent, LinkageIdx linkage_num);
    int sentence_link_cost(Sentence sent, LinkageIdx linkage_num);

    # **********************************************************************
    # *
    # * Functions that create and manipulate Linkages.
    # * When a Linkage is requested, the user is given a
    # * copy of all of the necessary information, and is responsible
    # * for freeing up the storage when he/she is finished, using
    # * the routines provided below.
    # *
    # **********************************************************************

    ctypedef struct Linkage_s:
        pass
    ctypedef Linkage_s * Linkage;

    ctypedef size_t WordIdx;
    ctypedef size_t LinkIdx;

    Linkage linkage_create(LinkageIdx linkage_num, Sentence sent, Parse_Options opts);
    void linkage_delete(Linkage linkage);
    size_t linkage_get_num_words(const Linkage linkage);
    size_t linkage_get_num_links(const Linkage linkage);
    WordIdx linkage_get_link_lword(const Linkage linkage, LinkIdx index);
    WordIdx linkage_get_link_rword(const Linkage linkage, LinkIdx index);
    int linkage_get_link_length(const Linkage linkage, LinkIdx index);
    const char * linkage_get_link_label(const Linkage linkage, LinkIdx index);
    const char * linkage_get_link_llabel(const Linkage linkage, LinkIdx index);
    const char * linkage_get_link_rlabel(const Linkage linkage, LinkIdx index);
    int linkage_get_link_num_domains(const Linkage linkage, LinkIdx index);
    const char ** linkage_get_link_domain_names(const Linkage linkage, LinkIdx index);
    const char ** linkage_get_words(const Linkage linkage);
    const char * linkage_get_disjunct_str(const Linkage linkage, WordIdx word_num);
    double linkage_get_disjunct_cost(const Linkage linkage, WordIdx word_num);
    double linkage_get_disjunct_corpus_score(const Linkage linkage, WordIdx word_num);
    const char * linkage_get_word(const Linkage linkage, WordIdx word_num);
    char * linkage_print_constituent_tree(Linkage linkage, ConstituentDisplayStyle mode);
    void linkage_free_constituent_tree_str(char *str);
    char * linkage_print_diagram(const Linkage linkage, bool display_walls, size_t screen_width);
    void linkage_free_diagram(char * str);
    char * linkage_print_postscript(const Linkage linkage, bool display_walls, bool print_ps_header);
    void linkage_free_postscript(char * str);
    char * linkage_print_disjuncts(const Linkage linkage);
    void linkage_free_disjuncts(char *str);
    char * linkage_print_links_and_domains(const Linkage linkage);
    void linkage_free_links_and_domains(char *str);
    char * linkage_print_pp_msgs(Linkage linkage);
    void linkage_free_pp_msgs(char * str);
    char * linkage_print_senses(Linkage linkage);
    void linkage_free_senses(char *str);
    int linkage_unused_word_cost(const Linkage linkage);
    double linkage_disjunct_cost(const Linkage linkage);
    int linkage_link_cost(const Linkage linkage);
    double linkage_corpus_cost(const Linkage linkage);
    const char * linkage_get_violation_name(const Linkage linkage);


    # **********************************************************************
    # *
    # * Internal functions -- do not use these in new code!
    # * These are not intended for general public use, but are required to
    # * get the link-parser executable to link under MSVC6.
    # *
    # ***********************************************************************/

    # void dict_display_word_expr(Dictionary dict, const char *, Parse_Options opts);
    # void dict_display_word_info(Dictionary dict, const char *, Parse_Options opts);
    # void left_print_string(FILE* fp, const char *, const char *);
    # bool lg_expand_disjunct_list(Sentence sent);
