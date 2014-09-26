module Classic = Practice_Classic
module Sequenceops = Practice_Sequenceops
module Classic_Puzzles = Practice_Classic_Puzzles
module Classic_Hiorder = Practice_Classic_Hiorder
module Sequenceops_Hiorder = Practice_Sequenceops_Hiorder
module Classic_Streams = Practice_Classic_Streams


let lib_main argv =
    Printf.printf "fact_i %s: %s\n" (Int64.to_string 5L)
		(Int64.to_string @@ Classic.fact_i 5L)


let () =
let (program, re) = (Sys.argv.(0), Str.regexp "lib_main") in
    try let _ = Str.search_forward re program 0 in
        lib_main (Sys.argv)
    with Not_found -> ()
(*
let () =
    if !Sys.interactive then () else lib_main (Sys.argv) ;
*)
