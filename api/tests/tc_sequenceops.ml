(** Sequence Ops test cases
*)

open OUnit
open Practice.Sequenceops

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ = Printf.printf "... TearDown\n"

let epsilon = 0.001
(* let (lst, revlst) = ([0;1;2;3;4], List.rev [0;1;2;3;4]) *)
let (lst, revlst) = (Util.range_cnt 5, List.rev @@ Util.range_cnt 5)

let test_findi _ = 
    let pred = (fun el -> el = 3) in
    List.iter (fun func_a -> 
        assert_equal (Some 3) (func_a pred lst)
        ; assert_equal (Some 1) (func_a pred revlst)
        ) [findi_r; findi_i]

let test_rev _ = List.iter (fun (func_a, xss) ->
    assert_equal (List.rev xss) (func_a xss)
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [rev_r; rev_i]


(** Suite of test cases
*)
let tcases = "Tc_sequenceops" >::: (List.map (fun (f, nm) -> 
        (nm >:: (bracket set_up f tear_down)))
    [(test_findi, "test_findi"); (test_rev, "test_rev")
    ])
