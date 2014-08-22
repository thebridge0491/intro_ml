#!/bin/sh
# (*
BOLT_CONFIG=resources/bolt_new.conf BISECT_FILE=_build/bisect_test exec ocaml -w +a-4 -safe-string -strict-sequence -short-paths -strict-formats -I `ocamlfind query bisect` -I `ocamlfind query bolt` -I src -I tests -I _build/src/swig -I _build/src/intro_ml $0 $@
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

#require "oUnit" ;;
#require "qcheck" ;;
#load "bisect.cma" ;;
#load "bolt.cma" ;;
#require "ctypes" ;;
#require "ctypes.foreign" ;;
(* #load "swig.cma" ;; *)

#require "intro_ml.util" ;;

(* #mod_use "intro_ml/foreignc.ml" ;; *)
#load "intro_ml-foreignc.cma" ;;
#mod_use "tc_classic.ml" ;;
#mod_use "tp_classic.ml" ;;

#use "ts_main.ml" ;;
