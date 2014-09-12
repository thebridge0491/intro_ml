(** Classic test cases
*)

open OUnit
open Practice.Classic

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ = Printf.printf "... TearDown\n"

let epsilon = 0.001

let test_square _ = List.iter (fun (func_a, n) ->
    assert_equal (n ** 2.0) (func_a n)
    ) @@ List.flatten @@ List.map (fun f ->
    	List.map (fun n -> (f, n)) [2.0; 11.0; 20.0]) [square_r; square_i]

let test_expt _ = List.iter (fun (func_a, b, n) ->
    (* assert_equal (truncate (b ** n)) (func_a b n) *)
    assert_equal ~cmp: (cmp_float ~epsilon: (0.0001 *. (b ** n))) 
    	(b ** n) (func_a b n)
    (* (* camlp4.listcomprehension *)
    ) [(f, b, n) | f <- [expt_r; expt_i] ; 
        b <- [2.0; 11.0; 20.0] ; n <- [3.0; 6.0; 10.0]] *) 
    ) @@ List.flatten @@ List.flatten @@ List.map (fun f ->
    	List.map (fun b -> List.map (fun n -> (f, b, n))
    	[3.0; 6.0; 10.0]) [2.0; 11.0; 20.0]) [expt_r; expt_i]

let test_sum_to _ = List.iter (fun func_a ->
    assert_equal 15L (func_a 5L 0L) ; assert_equal 75L (func_a 15L 10L)
    ) [sum_to_r; sum_to_i]

let test_fact _ = List.iter (fun (func_a, n) ->
    assert_equal (List.fold_left (fun a e -> Int64.mul a e) 1L
        (List.map Int64.of_int (Util.range_cnt ~start:1 @@ Int64.to_int n))) 
        (func_a n)
    ) @@ List.flatten @@ List.map (fun f ->
    	List.map (fun n -> (f, n)) [0L; 9L; 18L]) [fact_r; fact_i]

let test_fib _ = List.iter (fun func_a -> assert_equal 13 (func_a 7))
	[fib_r; fib_i]

let test_pascaltri _ = 
    let res = [[1]; [1; 1]; [1; 2; 1]; [1; 3; 3; 1];
        [1; 4; 6; 4; 1]; [1; 5; 10; 10; 5; 1]] in
    List.iter (fun func_a -> assert_equal res (func_a 5))
    	[pascaltri_mult; pascaltri_add]

let test_quot_rem _ = List.iter (fun (a, b) -> 
    assert_equal (a / b) (quot_m a b)
    ; assert_equal (a mod b) (rem_m a b)
    ) @@ List.flatten @@ List.map (fun a -> List.map (fun b -> (a, b))
    	[3; -3]) [10; -10]

let test_div_mod _ = List.iter (fun (a, b) ->
    assert_equal ~cmp: (cmp_float ~epsilon: 0.001) (a /. b) (div_m a b) 
    ; assert_equal ~cmp: (cmp_float ~epsilon: 0.001) (mod_float a b)
    	(mod_m a b) 
    ) @@ List.flatten @@ List.map (fun a -> List.map (fun b -> (a, b))
    	[3.0; -3.0]) [10.0; -10.0]

let test_gcd_lcm _ = List.iter (fun func_tup ->
    assert_equal 8 ((fst func_tup) [24; 16])
    ; assert_equal 4 ((fst func_tup) [24; 16; 12])
    ; assert_equal 48 ((snd func_tup) [24; 16])
    ; assert_equal 96 ((snd func_tup) [24; 16; 32])
    ) [(gcd_r, lcm_r); (gcd_i, lcm_i)]

let test_base_expand _ = List.iter (fun func_a ->
    assert_equal [1; 0; 1; 1] (func_a 2 11)
    ; assert_equal [1; 1; 0; 1] (func_a 4 81)
    ) [base_expand_r; base_expand_i]

let test_base_to10 _ = List.iter (fun func_a ->
    assert_equal 11 (func_a 2 [1; 0; 1; 1])
    ; assert_equal 81 (func_a 4 [1; 1; 0; 1])
    ) [base_to10_r; base_to10_i]

let test_range _ = 
	let (lst, revlst) = (Util.range_cnt 5, List.rev @@ Util.range_cnt 5) in
	List.iter (fun (fnStep, fnRg) ->
		assert_equal lst (fnRg 0 4)
		; assert_equal revlst (fnStep 0)
    ) [(range_step_r ~step:(-1) ~start:4, range_r)
		; (range_step_i ~step:(-1) ~start:4, range_i)]

let test_compose _ = 
    assert_equal ~cmp: (cmp_float ~epsilon: 0.0001) 2.0 
    	(compose1 (fun x -> x ** 2.0) sqrt 2.0)
    ; assert_equal 5 (compose1 List.length 
        (fun hi -> Util.range_cnt ~start:0 hi) 5)


(** Suite of test cases
*)
let tcases = "Tc_classic" >::: (List.map (fun (f, nm) -> 
        (nm >:: (bracket set_up f tear_down)))
    [(test_square, "test_square"); (test_expt, "test_expt")
    ; (test_sum_to, "test_sum_to"); (test_fact, "test_fact")
    ; (test_fib, "test_fib"); (test_pascaltri, "test_pascaltri")
    ; (test_quot_rem, "test_quot_rem"); (test_div_mod, "test_div_mod")
    ; (test_gcd_lcm, "test_gcd_lcm"); (test_base_expand, "test_base_expand")
    ; (test_base_to10, "test_base_to10"); (test_range, "test_range")
    ; (test_compose, "test_compose")
    ])
