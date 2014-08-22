open Ctypes
(*open PosixTypes*)
open Foreign

let fact_i = 
	foreign "fact_i" (int64_t @-> returning int64_t)
let fact_lp = 
	foreign "fact_lp" (int64_t @-> returning int64_t)

let expt_i = 
	foreign "expt_i" (float @-> float @-> returning float)
let expt_lp = 
	foreign "expt_lp" (float @-> float @-> returning float)


let lib_main argv =
    Printf.printf "fact_i %s: %s\n" (Int64.to_string 5L)
		(Int64.to_string @@ fact_i 5L)


let () =
let (program, re) = (Sys.argv.(0), Str.regexp "lib_main") in
    try let _ = Str.search_forward re program 0 in
        lib_main (Sys.argv)
    with Not_found -> ()
(*
let () =
    if !Sys.interactive then () else lib_main (Sys.argv) ;
*)
