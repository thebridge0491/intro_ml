(** Main test suite
*)

open OUnit2

(** Suite of test cases
*)
let suite = "Ts_main" >::: [Tc_collections.tcases; Tp_collections.tprops]

let main argv = 
    let _ = run_test_tt_main suite in ()

let () = 
    if !Sys.interactive then () else main (Sys.argv) ;
