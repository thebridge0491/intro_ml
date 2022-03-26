(** Main test suite
*)

open OUnit2

(** Suite of test cases
*)
let suite = "Ts_main" >::: [Tc_new.tcases; Tp_new.tprops]
(* let suite = "Ts_main" >::: [Tc_new.tcases; Tp_new.tprops; Tc_classic.tcases; Tp_classic.tprops] *)

let main argv = 
    let _ = run_test_tt_main suite in ()

let () = 
    if !Sys.interactive then () else main (Sys.argv) ;
