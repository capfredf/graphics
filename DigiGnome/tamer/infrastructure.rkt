#lang scribble/lp2

@(require "tamer.rkt")

@(tamer-story (tamer-story->libpath "infrastructure.rkt"))
@(define partner `(file ,(path->string (car (filter file-exists? (list (collection-file-path "makefile.rkt" (digimon-gnome))
                                                                       (build-path (digimon-world) "makefile.rkt")))))))
@(tamer-zone (make-tamer-zone))

@handbook-story{Hello, Hacker Hero!}

Every hacker needs a @hyperlink[@(cadr partner)]{@italic{makefile.rkt}} (and some
@hyperlink[@(collection-file-path "digitama/runtime.rkt" (digimon-gnome))]{minimal common code base})
to make life simple. However testing building routines always makes nonsense but costs high,
thus I will focus on the @seclink["rules"]{project organization rules}.

@chunk[<makefile>
       {module story racket
         |<makefile taming start>|
         
         |<ready? help!>|
         |<hello rules!>|}
                                                  
       |<tamer battle>|]

where @chunk[|<makefile taming start>|
             (require "tamer.rkt")
             
             (tamer-story (tamer-story->libpath "infrastructure.rkt"))
             (define partner `(file ,(format "~a/makefile.rkt" (digimon-world))))]

@tamer-smart-summary[]

@handbook-scenario{Ready? Let@literal{'}s have a try!}

@chunk[|<ready? help!>|
       (define-values {make out err $? setup teardown}
         (values (dynamic-require partner 'main {λ _ #false})
                 (open-output-bytes 'stdout)
                 (open-output-bytes 'stderr)
                 (make-parameter +NaN.0)
                 {λ argv {λ _ (parameterize ([current-output-port out]
                                             [current-error-port err]
                                             [exit-handler $?])
                                (apply make argv))}}
                 {λ _ (void (get-output-bytes out #true)
                            (get-output-bytes err #true)
                            ($? +NaN.0))}))
       
       (define-tamer-suite spec-examples "Ready? It works!"
         (list |<testsuite: Okay, it works!>|))]

Although normal @bold{Racket} script doesn@literal{'}t require the so-called @racketidfont{main} routine,
I still prefer to start with @defproc[{main [argument string?] ...} void?]

You may have already familiar with the @hyperlink["http://en.wikipedia.org/wiki/Make_(software)"]{GNU Make},
nonetheless you are still free to check the options first. Normal @bold{Racket} program always knows
@exec{@|-~-|h} or @exec{@|-~-|@|-~-|help} option:

@tamer-action[((dynamic-require/expose (tamer-story) 'make) "--help")
              (code:comment @#,t{See, @racketcommentfont{@italic{makefile}} complains that @racketcommentfont{@bold{Scribble}} is killed by accident.})]

Now it@literal{'}s time to check the testing system itself 

@tamer-note['spec-examples]
@chunk[|<testsuite: Okay, it works!>|
       (test-suite "makefile.rkt usage"
                   (test-suite "make --silent --help"
                               #:before (setup "--silent" "--help")
                               #:after teardown
                               (test-pred "should exit normally" zero? ($?))
                               (test-pred "should have to quiet"
                                          zero? (file-position out)))
                   (test-suite "make --silent love"
                               #:before (setup "--silent" "love")
                               #:after teardown
                               (test-false "should abort" (zero? ($?)))
                               (test-pred "should report errors"
                                          positive? (file-position err))))]

@subsection[#:tag "rules"]{Scenario: The rules serve you!}

@chunk[|<hello rules!>|
       (define digidirs (filter {λ [sub] (and (directory-exists? sub)
                                              (regexp-match? #px"/[^.][^/.]+$" sub))}
                                (directory-list (digimon-world) #:build? #true)))
       
       |<rule: info.rkt>|
       |<rule: readme.md>|]

Since @italic{Behavior Driven Development} is the evolution of @italic{Test Driven Development} which does not define
what exactly should be tested and how would the tests be performed correct. The term @italic{Architecture} is all about designing
rules, and this story is all about building system. So apart from conventions, we need a sort of rules that the @italic{makefile.rkt}
(and systems it builds) should satisfy.

@margin-note{Meanwhile @italic{parallel building} is not supported.}

@subsubsection{Rules on project organization}

@chunk[|<rule: info.rkt>|
       (require setup/getinfo)
       
       (define info-root (get-info/full (digimon-world)))
       
       (define-tamer-suite rules:info.rkt "Rules: info.rkt settings"
         (cons (test-suite "with /info.rkt"
                           |<rules: ROOT/info.rkt>|)
               (for/list ([digidir (in-list digidirs)])
                 (define digimon (file-name-from-path digidir))
                 (define info-ref (get-info/full digidir))
                 (test-suite (format "with /~a/info.rkt" digimon)
                             |<rules: DIGIMON/info.rkt>|))))]

@tamer-note['rules:info.rkt]
@(itemlist @item{@bold{Rule 1} The entire project is a multi-collection package,
                  non-hidden directories within it are considered as the subprojects.}
           @item{@bold{Rule 2} Each subproject should have an explicit name,
                  even if the name is the same as its directory.}
           @item{@bold{Rule 3} @racket[compile-collection-zos] and friends should never touch these files or directories:
                  @filepath{makefile.rkt}, @filepath{submake.rkt}, @filepath{info.rkt},
                  @filepath[(path->string (file-name-from-path (digimon-stone)))] and
                  @filepath[(path->string (file-name-from-path (digimon-tamer)))].}
           @item{@bold{Rule 4} @exec{raco test} should do nothing since we would do testing
                  in a more controllable way.})

@chunk[|<rules: ROOT/info.rkt>|
       (test-case "Rule 1: multi"
                  (check-not-false info-root "/info.rkt not found!")
                  (check-equal? (info-root 'collection) 'multi
                                "'collection should be 'multi")
                  (check-equal? (info-root 'compile-omit-paths) 'all
                                "'compile-omit-paths should be 'all")
                  (check-equal? (info-root 'test-omit-paths) 'all
                                "'test-omit-paths should be 'all"))
       (test-case "Subprojects should have their own info.rkt"
                  (check-pred positive? (length digidirs) "No project found!")
                  (for ([digidir (in-list digidirs)])
                    (check-pred file-exists? (build-path digidir "info.rkt")
                                (format "/~a/info.rkt not found!"
                                        (file-name-from-path digidir)))))]

@chunk[|<rules: DIGIMON/info.rkt>|
       (test-case "Rule 2: collection"
                  (with-check-info
                   {{'info.rkt (build-path digimon "info.rkt")}}
                   (check-pred string? (info-ref 'collection)
                               "'collection should be string!")))
       (test-case "Rule 3: compile-omit-paths"
                  (with-check-info
                   {{'info.rkt (build-path digimon "info.rkt")}}
                   (let ([compile-omit-paths (info-ref 'compile-omit-paths)])
                     (check-not-false compile-omit-paths
                                      "'compile-omit-paths not defined!")
                     (if (equal? compile-omit-paths 'all)
                         (check-true #true)
                         (for ([omit (in-list (list "makefile.rkt" "submake.rkt"
                                                    "info.rkt" "stone" "tamer"))])
                           (check-not-false (member omit compile-omit-paths)
                                            (format "~a should in compile-omit-paths"
                                                    omit)))))))
       (test-case "Rule 4: test-omit-paths"
                  (with-check-info
                   {{'info.rkt (build-path digimon "info.rkt")}}
                   (let ([test-omit-paths (info-ref 'test-omit-paths)])
                     (check-not-false test-omit-paths
                                      "'test-omit-paths not defined!")
                     (check-equal? test-omit-paths 'all
                                   "'test-omit-paths should be 'all!"))))]

@margin-note{Documentation are deployed in @hyperlink["gyoudmon/org"]{my website} with @bold{Scribble},
                                           while sources are hosted in @hyperlink["github.com/digital-world"]{Github} with @bold{Markdown}.}
@subsubsection{Rules on project documentation}

@chunk[|<rule: readme.md>|
       (match-define {list top.scrbl sub.scrbl}
         (map (compose1 (curry find-relative-path (digimon-zone)) build-path)
              (list (digimon-stone) (digimon-tamer))
              (list "readme.scrbl" "handbook.scrbl")))
       
       (define-tamer-suite rules:readme.md "Rules: README.md dependent"
         (cons (test-suite "for /README.md"
                           |<rules: ROOT/readme.md>|)
               (for/list ([digidir (in-list digidirs)])
                 (define digimon (file-name-from-path digidir))
                 (test-suite (format "for /~a/README.md" digimon)
                             |<rules: DIGIMON/readme.md>|))))]

@tamer-note['rules:readme.md]
@(itemlist @item{@bold{Rule 5} The project@literal{'}s toplevel @italic{README.md} is designated as the @italic{main-toc} of @bold{Scribble}.}
           @item{@bold{Rule 6} Each subproject@literal{'}s @italic{README.md} follows its @italic{handbook}@literal{'}s index page.})

@chunk[|<rules: ROOT/readme.md>|
       (test-pred (format "Rule 5: ~a/~a" (digimon-gnome) top.scrbl)
                  file-exists? (build-path (digimon-zone) top.scrbl))]

@chunk[|<rules: DIGIMON/readme.md>|
       (test-pred (format "Rule 6: ~a/~a" digimon sub.scrbl)
                  file-exists? (build-path digidir sub.scrbl))]

@handbook-scenario{What if the @italic{handbook} is unavaliable?}

Furthermore, the @italic{handbook} itself is the standard test report, but it@literal{'}s still reasonable
to check the system in some more convenient ways. Hence we have @chunk[|<tamer battle>|
                                                                       {module main racket
                                                                         |<makefile taming start>|
                                                                         
                                                                         (exit (tamer-spec))}]

Run @exec{racket «@smaller{tamer files}»} we will get @hyperlink["http://hspec.github.io"]{@italic{hspec-like}} report.

Technically speaking, @exec{raco test --submodule main} is always there,
although that way is not recommended, and is omitted by @filepath{info.rkt}.