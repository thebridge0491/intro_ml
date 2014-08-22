(** Main test suite
*)

open OUnit

(** Suite of test cases
*)
let suite = "Ts_main" >::: [Tc_classic.tcases; Tc_sequenceops.tcases
    ; Tp_classic.tprops; Tp_sequenceops.tprops]

let main argv = 
    let _ = run_test_tt_main suite in ()

let () = 
    if !Sys.interactive then () else main (Sys.argv) ;
