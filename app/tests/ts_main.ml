(** Main test suite
*)

open OUnit

(** Suite of test cases
*)
let suite = "Ts_main" >::: [Tc_new.tcases; Tp_new.tprops]

let main argv = 
    let _ = run_test_tt_main suite in ()

let () = 
    if !Sys.interactive then () else main (Sys.argv) ;
