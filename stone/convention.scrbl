#lang scribble/base

@(require racket/function)

@(require "scribble.rkt")

@title{Project Conventions}
How to build a @italic{Digital World}? Okay, we don@literal{'}t start with the @italic{File Island}, but we own some concepts from the @italic{Digimon Series}.

@section{Hierarchy}
@bold{Note} Project or Subprojects are organized as the @italic{digimons}, and each of them may be separated into several repositories. 

@(itemlist @item{@bold{digitama} is the egg of @italic{digimons}. Namely it works like @tt{src} @bold{and} @tt{libraries}/@tt{frameworks}.}
           @item{@bold{digivice} is the interface for users to talk with @italic{digimons}. Namely it works like @tt{bin}.}
           @item{@bold{tamer} is the interface for developers to train the @italic{digimons}. Namely it works like @tt{test}.}
           @item{>  >@bold{behavior} shares the same name and concepts as in @italic{Behavior Driven Development}.}
           @item{>  >@bold{combat} occurs in real world after @italic{digimons} start their own lives.}
           @item{@bold{island} manages guilds of @italic{digimons}. Hmm... Sounds weird, nonetheless, try @tt{htdocs} or @tt{webroot}:stuck_out_tongue_winking_eye:.}
           @item{@bold{stone} stores immutable meta-information or ancient sources to be translated. Yes, it@literal{'}s the @italic{Rosetta Stone}.}
           @item{@bold{village} is the playground of @italic{digimon} friends. Each directory within it is a subproject.})

@section{Version}
Obviousely, our @italic{digimons} have their own life cycle.

@(let ([smart-stage (curry smart-radiobox (car (regexp-match #px"[^-]+" (info-ref 'version))))])
   @(itemlist @smart-stage["Baby I"]{The 1st stage of @italic{digimon evolution} hatching straightly from her @italic{digitama}. Namely it@literal{'}s the @tt{Alpha Version}.}
              @smart-stage["Baby II"]{The 2nd stage of @italic{digimon evolution} evolving quickly from @bold{Baby I}. Namely it@literal{'}s the @tt{Beta Version}.}
              @smart-stage["Child"]{The 3rd stage of @italic{digimon evolution} evolving from @bold{Baby II}. At the time @italic{digimons} are strong enough to live on their own.}))