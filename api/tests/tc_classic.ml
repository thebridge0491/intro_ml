(** Classic test cases
*)

open OUnit2
open Practice.Classic

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ ctx = Printf.printf "... TearDown\n"

let epsilon = 0.001

let test_square _ = List.iter (fun n ->
	let ans = n ** 2.0 in
	List.iter (fun func_a ->
		assert_equal ans (func_a n)
		) [square_r; square_i; square_f; square_u]
	;
	let res_strm, res_u = squares_strm (), squares_u () in
    List.iter (fun _ -> ignore (Stream.next res_strm)) 
		(Util.range_cnt (truncate n))
	; assert_equal ans (Stream.next res_strm)
	; assert_equal ans (BatLazyList.at res_u @@ truncate n)
	) [2.0; 11.0; 20.0]

let test_expt _ = List.iter (fun (b, n) ->
	let ans = b ** n in
	List.iter (fun func_a ->
		(* assert_equal (truncate (b ** n)) (func_a b n) *)
		assert_equal ~cmp: (cmp_float ~epsilon: (0.0001 *. ans)) 
			ans (func_a b n)
		) [expt_r; expt_i; expt_f; expt_u; fast_expt_r; fast_expt_i]
	;
    let res_strm, res_u = expts_strm b, expts_u b in
    List.iter (fun _ -> ignore (Stream.next res_strm)) 
		(Util.range_cnt @@ truncate n)
    ; assert_equal ~cmp:(cmp_float ~epsilon:(0.0001 *. ans)) 
        ans (Stream.next res_strm)
    ; assert_equal ~cmp:(cmp_float ~epsilon:(0.0001 *. ans)) 
        ans (BatLazyList.at res_u @@ truncate n)
	) @@ List.map2 (fun b n -> (b, n)) [2.0; 11.0; 20.0] [3.0; 6.0; 10.0]

let test_sum_to _ = List.iter (fun (hi, lo) ->
	let ans = List.fold_left Int64.add 0L 
		@@ List.map Int64.of_int (Util.range_cnt ~start:(Int64.to_int lo) 
			(Int64.to_int hi - Int64.to_int lo + 1)) in
    List.iter (fun func_a ->
        assert_equal ans (func_a hi lo)
        ) [sum_to_r; sum_to_i; sum_to_f; sum_to_u]
    ; 
    let (res_strm, res_u) = (sums_strm lo, sums_u lo) in
    List.iter (fun _ -> ignore (Stream.next res_strm)) 
		(Util.range_cnt (Int64.to_int hi - Int64.to_int lo))
    ; assert_equal ans (Stream.next res_strm)
    ; assert_equal ans (BatLazyList.at res_u @@ Int64.to_int (Int64.sub hi lo))
    ) [(5L, 0L); (15L, 10L)]

let test_fact _ = List.iter (fun n ->
    let ans = List.fold_left Int64.mul 1L @@
        List.map Int64.of_int (Util.range_cnt ~start:1 @@ Int64.to_int n) in
    List.iter (fun func_a ->
        assert_equal ans (func_a n)
        ) [fact_r; fact_i; fact_f; fact_u]
    ;
    let res_strm, res_u = facts_strm (), facts_u () in
    List.iter (fun _ -> ignore (Stream.next res_strm)) 
		(Util.range_cnt @@ Int64.to_int n)
    ; assert_equal ans (Stream.next res_strm)
    ; assert_equal ans (BatLazyList.at res_u @@ Int64.to_int n)
    ) [0L; 9L; 18L]

let test_fib _ = List.iter (fun (n, ans) ->
	List.iter (fun func_a -> assert_equal ans (func_a n))
		[fib_r; fib_i; fib_f; fib_u]
	; 
	let res_strm, res_u = fibs_strm (), fibs_u () in
	List.iter (fun _ -> ignore (Stream.next res_strm)) (Util.range_cnt n)
	; assert_equal ans (Stream.next res_strm)
	; assert_equal ans (BatLazyList.at res_u n)
    ) [(7, 13); (8, 21); (9, 34)]

let test_pascaltri _ = 
    let ans = [[1]; [1; 1]; [1; 2; 1]; [1; 3; 3; 1];
        [1; 4; 6; 4; 1]; [1; 5; 10; 10; 5; 1]] in
    List.iter (fun func_a -> assert_equal ans (func_a 5))
    	[pascaltri_mult; pascaltri_add; pascaltri_f; pascaltri_u]
    ; 
    let res_strm, res_u = pascalrows_strm (), pascalrows_u () in
    assert_equal ans (Stream.npeek (5 + 1) res_strm)
    ; assert_equal ans (BatLazyList.to_list @@ BatLazyList.take (5 + 1) res_u)

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
    ) [(gcd_r, lcm_r); (gcd_i, lcm_i); (gcd_f, lcm_f); (gcd_u, lcm_u)]

let test_base_expand _ = List.iter (fun func_a ->
    assert_equal [1; 0; 1; 1] (func_a 2 11)
    ; assert_equal [1; 1; 0; 1] (func_a 4 81)
    ) [base_expand_r; base_expand_i; base_expand_f; base_expand_u]

let test_base_to10 _ = List.iter (fun func_a ->
    assert_equal 11 (func_a 2 [1; 0; 1; 1])
    ; assert_equal 81 (func_a 4 [1; 1; 0; 1])
    ) [base_to10_r; base_to10_i; base_to10_f; base_to10_u]

let test_range _ = 
	let (lst, revlst) = (Util.range_cnt 5, List.rev @@ Util.range_cnt 5) in
	List.iter (fun (fnStep, fnRg) ->
		assert_equal lst (fnRg 0 4)
		; assert_equal revlst (fnStep 0)
    ) [(range_step_r ~step:(-1) ~start:4, range_r)
		; (range_step_i ~step:(-1) ~start:4, range_i)
		; (range_step_f ~step:(-1) ~start:4, range_f)
		; (range_step_u ~step:(-1) ~start:4, range_u)]

let test_compose _ = 
    assert_equal ~cmp: (cmp_float ~epsilon: 0.0001) 2.0 
    	(compose1 (fun x -> x ** 2.0) sqrt 2.0)
    ; assert_equal 5 (compose1 List.length 
        (fun hi -> Util.range_cnt ~start:0 hi) 5)


(** Suite of test cases
*)
let tcases = "Tc_classic" >::: (List.map (fun (f, nm) -> 
        (nm >:: (fun ctx -> f @@ bracket set_up tear_down ctx)))
    [(test_square, "test_square"); (test_expt, "test_expt")
    ; (test_sum_to, "test_sum_to"); (test_fact, "test_fact")
    ; (test_fib, "test_fib"); (test_pascaltri, "test_pascaltri")
    ; (test_quot_rem, "test_quot_rem"); (test_div_mod, "test_div_mod")
    ; (test_gcd_lcm, "test_gcd_lcm"); (test_base_expand, "test_base_expand")
    ; (test_base_to10, "test_base_to10"); (test_range, "test_range")
    ; (test_compose, "test_compose")
    ])
