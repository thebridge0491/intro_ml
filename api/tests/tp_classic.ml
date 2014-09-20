(** Classic test properties
*)

module Q = QCheck
open Practice.Classic

let epsilon = 0.001
let _euclid m n = 
    let rec iter a b = match b with | 0 -> a | _ -> iter b (a mod b)
in iter m n

(*let genItems ?f:(f=(fun e -> e)) gen0 = Q.(map f gen0)
let genTup2Items gen0 gen1 = Q.(pair gen0 gen1)
*)

let prop_square arbFlt = Q.(Test.make ~count:100 arbFlt
	~name:"square n == n ** 2.0" 
	(fun n -> 
		let ans = n ** 2.0 in
		List.fold_left (fun a f -> a && Util.in_epsilon ~tolerance:(epsilon *. ans) ans (f n))
			true [square_r; square_i; square_f; square_u]))

let prop_expt arb2Flts = Q.(Test.make ~count:100 arb2Flts
	~name:"expt b n == b ** n" 
	(fun (b, n) -> 
		let ans = b ** n in
		List.fold_left (fun a f -> a && Util.in_epsilon ~tolerance:(epsilon *. ans) ans (f b n))
			true [expt_r; expt_i; expt_f; expt_u; fast_expt_r; fast_expt_i]))

let prop_sum arb2Longs = Q.(Test.make ~count:100 arb2Longs
	~name:"sum hi lo == List.sum [lo -- hi]" 
	(fun (hi, lo) -> 
		let ans = match hi >= lo with
			| true -> List.fold_left Int64.add lo @@
				List.map Int64.of_int
					(Util.range_cnt ~start:(1 + Int64.to_int lo) 
					@@ Int64.to_int hi - Int64.to_int lo)
			| _ -> 0L in
		List.fold_left (fun a f -> a && f hi lo = ans) true 
			[sum_to_r; sum_to_i; sum_to_f; sum_to_u]))

let prop_fact arbLong = Q.(Test.make ~count:100 arbLong
	~name:"fact n == List.product [1 -- n]" 
	(fun n -> 
		let ans = List.fold_left Int64.mul 1L @@
			List.map Int64.of_int (Util.range_cnt ~start:1 @@ Int64.to_int n) in
		List.fold_left (fun a f -> a && f n = ans) true 
			[fact_r; fact_i; fact_f; fact_u]))

let prop_fib arbInt = Q.(Test.make ~count:100 arbInt
	~name:"fib n == ?? n"
	(fun n -> 
		let ans = snd @@ List.fold_left (fun (s0, s1) _ -> (s0 + s1, s0)) 
			(0, 1) (Util.range_cnt (n + 1)) in
		List.fold_left (fun a f -> a && f n = ans) true 
			[fib_r; fib_i; fib_f; fib_u]))

let prop_pascaltri arbInt = Q.(Test.make ~count:100 arbInt
	~name:"pascaltri rows == ?? rows"
	(fun rows -> 
		let validNumRows res = List.length res = rows + 1 in
		let validLenRow n r = List.length r = n + 1 in
		let validSumRow n r = List.fold_left (+) 0 r = 
			truncate @@ 2.0 ** float_of_int n in
		List.fold_left (fun a f -> a && validNumRows (f rows) &&
			fst @@ List.fold_left (fun (a1, n) r -> (a1 && validLenRow n r
			&& validSumRow n r, n + 1)) (true, 0) (f rows)) true 
			[pascaltri_mult; pascaltri_add; pascaltri_f; pascaltri_u]))

let prop_quot_rem arb2Ints = Q.(Test.make ~count:100 arb2Ints
	~name:"quot_rem m n == quotRem m n"
	(fun (m, n) -> 
		let (ansQ, ansR) = (m / n, m - (m / n) * n) in
		List.fold_left (fun a (fnQ, fnR) -> a && fnQ m n = ansQ && 
			fnR m n = ansR) true 
			[(quot_m, rem_m)]))

let prop_div_mod arb2Flts = Q.(Test.make ~count:100 arb2Flts
	~name:"div_mod m n == divMod m n"
	(fun (m, n) -> 
		let (ansD, ansM) = (m /. n, mod_float m n) in
		List.fold_left (fun a (fnD, fnM) -> a && fnD m n = ansD && 
			fnM m n = ansM) true 
			[(div_m, mod_m)]))

let prop_gcd_lcm arbInts = Q.(Test.make ~count:100 arbInts
	~name:"gcd_lcm m n == (gcd m n, lcm m n)"
	(fun mss -> match mss with
		| m::ms ->
			let ansG = List.fold_left _euclid m ms in
			let ansL = List.fold_left (fun a b -> a * b / (_euclid a b))
				m ms in
			List.fold_left (fun a (fnG, fnL) -> a && fnG mss = ansG && 
				fnL mss = ansL) true 
				[(gcd_r, lcm_r); (gcd_i, lcm_i); (gcd_f, lcm_f)
				; (gcd_u, lcm_u)]
		| _ -> true))

let prop_base_expand arb2Ints = Q.(Test.make ~count:100 arb2Ints
	~name:"base_expand b n == ?? b n"
	(fun (b, n) -> 
		let ans = fst @@ List.fold_left (fun (acc, num) _ -> match num with
			| 0 -> (acc, num / b)
			| _ -> (num mod b :: acc, num / b)) ([], n) 
			@@ Util.range_cnt ((truncate @@ log (float_of_int n) /. 
				log (float_of_int b)) + 1) in
		List.fold_left (fun a f -> a && f b n = ans) true 
			[base_expand_r; base_expand_i; base_expand_f; base_expand_u]))

let prop_base_to10 b arbInts = Q.(Test.make ~count:100 arbInts
	~name:(Printf.sprintf "base_to10 %d n == ?? %d n" b b)
	(fun xss -> 
		let ans = snd @@ List.fold_right (fun e (h, t) -> 
			(h + 1, t + (e * (truncate (float_of_int b ** float_of_int h)))))
			xss (0, 0) in
		List.fold_left (fun a f -> a && f b xss = ans) true 
			[base_to10_r; base_to10_i; base_to10_f; base_to10_u]))

let prop_range arb2Ints = Q.(Test.make ~count:100 arb2Ints
	~name:"range start stop == [start..stop]"
	(fun (start, stop) -> 
		let ans = (match stop >= start with
			| true -> Array.to_list @@ 
				Array.init (stop - start + 1) (fun e -> e + start) 
			| _ -> []) in
		List.fold_left (fun a (fnStep, fnRg) -> a && fnRg start stop = ans
			&& fnStep start = List.rev ans) true 
			[(range_step_r ~step:(-1) ~start:stop, range_r)
				; (range_step_i ~step:(-1) ~start:stop, range_i)
				; (range_step_f ~step:(-1) ~start:stop, range_f)
				; (range_step_u ~step:(-1) ~start:stop, range_u)]))

let prop_composeInt f g arbInt = Q.(Test.make ~count:100 arbInt
	~name:"composeInt f g x == f g x"
	(fun x -> 
		let ans = f @@ g x in
		List.fold_left (fun a comp -> a && comp f g x = ans) true 
			[compose1]))

let prop_composeFlt f g arbFlt = Q.(Test.make ~count:100 arbFlt
	~name:"composeFlt f g x == f g x"
	(fun x -> 
		let ans = f @@ g x in
		List.fold_left (fun a comp -> a && 
			Util.in_epsilon ~tolerance:(epsilon *. ans) ans (comp f g x)) true 
			[compose1]))


(** Suite of test properties
*)
let tprops = OUnit.( >::: ) "Tp_classic" (List.map 
	(QCheck_runner.to_ounit_test ~verbose:true)
	[prop_expt Q.(pair (map float_of_int (1 -- 20)) 
		(map float_of_int (2 -- 10)))
	; prop_square Q.(map float_of_int (1 -- 20))
	; prop_sum Q.(pair (map Int64.of_int (0 -- 18)) 
		(map Int64.of_int (0 -- 18)))
	; prop_fact Q.(map Int64.of_int (0 -- 18)); prop_fib Q.(0 -- 20)
	; prop_pascaltri Q.(0 -- 15)
	; prop_quot_rem Q.(pair (-100 -- 100) (choose [(-100 -- -1); (1 -- 100)]))
	; prop_div_mod Q.(pair (map float_of_int (-100 -- 100)) 
		(map float_of_int (choose [(-100 -- -1); (1 -- 100)])))
	; prop_gcd_lcm Q.(list_of_size Gen.(1 -- 19) 
		(choose [(-500 -- -1); (1 -- 500)]))
	; prop_base_expand Q.(pair (2 -- 12) (0 -- 250))
	; prop_base_to10 2 Q.(list_of_size Gen.(1 -- 10) (0 -- 1))
	; prop_base_to10 16 Q.(list_of_size Gen.(1 -- 10) (0 -- 15))
	; prop_range Q.(pair (0 -- 25) (0 -- 25))
	; prop_composeInt List.length Util.range_cnt Q.(0 -- 20)
	; prop_composeFlt (fun n -> n ** 2.0) sqrt Q.(map float_of_int (0 -- 20))
	])
