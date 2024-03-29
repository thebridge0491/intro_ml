(** Classic test properties
*)

module Q = QCheck
open Foreignc

let epsilon = 0.001

(*let genItems ?f:(f=(fun e -> e)) gen0 = Q.(map f gen0)
let genTup2Items gen0 gen1 = Q.(pair gen0 gen1)
*)

let prop_fact arbLong = Q.(Test.make ~count:100 arbLong
	~name:"fact n == List.product [1 -- n]" 
	(fun n -> 
		let ans = List.fold_left (fun a e -> Int64.mul a e) 1L @@
			List.map Int64.of_int (Util.range_cnt ~start:1 @@ Int64.to_int n) in
		List.fold_left (fun a f -> a && f n = ans) true 
			[fact_lp; fact_i]))

let prop_expt arb2Flts = Q.(Test.make ~count:100 arb2Flts
	~name:"expt b n == b ** n" 
	(fun (b, n) -> 
		let ans = b ** n in
		List.fold_left (fun a f -> a && Util.in_epsilon ~tolerance:(epsilon *. ans) 
			ans (f b n)) true [expt_lp; expt_i]))


(** Suite of test properties
*)
let tprops = OUnit2.( >::: ) "Tp_classic" (List.map 
	(QCheck_runner.to_ounit2_test)
	[prop_fact Q.(map Int64.of_int (0 -- 18))
	; prop_expt Q.(pair (map float_of_int (1 -- 20)) (map float_of_int (2 -- 10)))
	])
