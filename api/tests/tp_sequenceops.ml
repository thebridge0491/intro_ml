(** Sequence Ops test properties
*)

module Q = QCheck
open Practice.Sequenceops

let epsilon = 0.001

let genItems ?f:(f=(fun e -> e)) gen0 = Q.(map f gen0)
let genTup2Items gen0 gen1 = Q.(pair gen0 gen1)
let genInts = genItems Q.(-250 -- 250)

let prop_findi pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"findi == List.findi" 
	(fun xs -> 
		let ans = snd @@ List.fold_left (fun (ndx, idx) el -> 
			match pred1 el && idx = None with
				| true -> (ndx + 1, Some ndx)
				| _ -> (ndx + 1, idx)) (0, None) xs in
		List.fold_left (fun a f -> a && f pred1 xs = ans) true 
			[findi_r; findi_i]))

let prop_reverse arbXs = Q.(Test.make ~count:100 arbXs
	~name:"reverse == List.rev" 
	(fun xs -> 
		let ans = List.rev xs in
		List.fold_left (fun a f -> a && f xs = ans) true 
			[rev_r; rev_i]))


(** Suite of test properties
*)
let tprops = OUnit.( >::: ) "Tp_sequenceops" (List.map 
	(QCheck_runner.to_ounit_test ~verbose:true)
	[prop_findi (fun e -> 0 = e mod 2) Q.(list genInts)
	; prop_reverse Q.(list genInts)
	])
