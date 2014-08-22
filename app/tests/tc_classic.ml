(** Classic test cases
*)

open OUnit
open Classic

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ = Printf.printf "... TearDown\n"

let range_cnt ?(start=0) cnt = 
    Array.to_list @@ Array.init cnt (fun e -> e + start)

let epsilon = 0.001
let in_epsilon ?(tolerance=0.001) a b =
    let delta = abs_float tolerance in
    (* (a -. delta) <= b && (a +. delta) >= b *)
    not ((a +. delta) < b) && not ((b +. delta) < a)

let test_fact _ = List.iter (fun (func_a, n) ->
    assert_equal (List.fold_left (fun a e -> Int64.mul a e) 1L
        (List.map Int64.of_int (range_cnt ~start:1 @@ Int64.to_int n)))
        (func_a n)
    ) @@ List.flatten @@ List.map (fun f ->
    	List.map (fun n -> (f, n)) [0L; 9L; 18L]) [fact_lp; fact_i]

let test_expt _ = List.iter (fun (func_a, b, n) ->
    (* assert_equal (truncate (b ** n)) (truncate (func_a b n)) *)
    (* assert_equal ~cmp:(cmp_float ~epsilon:(0.0001 *. (b ** n))) 
    	(b ** n) (func_a b n) *)
    assert_equal ~cmp:(in_epsilon ~tolerance:(0.0001 *. (b ** n))) 
    	(b ** n) (func_a b n)
    ) @@ List.flatten @@ List.flatten @@ List.map (fun f ->
    	List.map (fun b -> List.map (fun n -> (f, b, n))
    	[3.0; 6.0; 10.0]) [2.0; 11.0; 20.0]) [expt_lp; expt_i]


(** Suite of test cases
*)
let tcases = "Tc_classic" >::: (List.map (fun (f, nm) -> 
        (nm >:: (bracket set_up f tear_down)))
    [(test_fact, "test_fact"); (test_expt, "test_expt")
    ])
