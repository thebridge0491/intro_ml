#!/bin/sh
# (*
BOLT_CONFIG=resources/bolt_new.conf BISECT_FILE=_build/bisect_main exec ocaml -w +a-4 -safe-string -strict-sequence -short-paths -strict-formats -I `ocamlfind query bisect` -I `ocamlfind query bolt` -I src -I _build/src/intro_ml $0 $@
exit
*) use "topfind" ;;
(* #!/usr/bin/env ocaml *)

(* Added by OPAM. *)
let () =
  try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
  with Not_found -> ()
;;

(* added by user to pre-load libraries *)
#use "topfind" ;;
#thread ;;

#require "unix" ;;  (* #load "unix.cma" ;; *)
#require "dynlink" ;; (* #load "dynlink.cma" ;; *)
#require "str" ;;   (* #load "str.cma" ;; *)
#require "num" ;;   (* #load "nums.cma" ;; *)

(* #directory "~/.opam/system/lib/bolt" ;; *)

#require "bytes" ;;
#require "bigarray" ;;

(* for Core
#require "core.top" ;;
#require "ppx_sexp_conv" ;;
open Core.Std ;; *)

(* for Batteries            (* multi-threaded or [single]-threaded *)
#require "batteriesThread" ;;     (* #require "batteries" ;; *)
open BatteriesThread ;;           (* open Batteries ;; *) *)

#load "bisect.cma" ;;
#load "bolt.cma" ;;
#require "pcre" ;;
#require "inifiles" ;;
#require "yojson" ;;
#require "ezjsonm" ;;

(* #load "intro_ml-intro.cma" ;; *)
#mod_use "intro_ml/intro.ml" ;;
#mod_use "intro_ml/person.ml" ;;
#use "intro_ml/main.ml" ;;

(* Main.main ([|Sys.argv.(0); "-u"; "IMComputer"; "-n"; "11"|]) ;; *)
(* Main.main Sys.argv ;; *)
