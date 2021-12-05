(** Sequence Ops test properties
*)

module Q = QCheck
open Practice.Sequenceops

let epsilon = 0.001

let genItems ?f:(f=(fun e -> e)) gen0 = Q.(map f gen0)
let genTup2Items gen0 gen1 = Q.(pair gen0 gen1)
let genInts = genItems Q.(-250 -- 250)

let _unfold_right_i func seed =
    let rec iter cur acc = match func cur with
        | None -> acc | Some (a, new_cur) -> iter new_cur (a :: acc)
in iter seed []

let rec _unfold_left_r func seed = match func seed with
    | None -> [] | Some (a, new_seed) -> a :: _unfold_left_r func new_seed

let prop_tabulate func arbInt = Q.(Test.make ~count:100 arbInt
	~name:"tabulate f == List.fold_right f"
	(fun n -> 
		let ans = List.fold_right (fun e a -> func e :: a)
			(Util.range_cnt n) [] in
		List.fold_left (fun a f -> a && f func n = ans) true
			[tabulate_r; tabulate_i; tabulate_f; tabulate_u]))

let prop_length arbXs = Q.(Test.make ~count:100 arbXs
	~name:"length == List.length"
	(fun xs -> 
		let ans = List.length xs in
		List.fold_left (fun a f -> a && f xs = ans) true
			[length_r; length_i; length_f; length_u]))

let prop_nth arbNXs = Q.(Test.make ~count:100 arbNXs
	~name:"nth == List.nth"
	(fun (n, xs) -> 
		let ans = match n < List.length xs with
			| true -> Some (List.nth xs n) | _ -> None in
		List.fold_left (fun a f -> a && f n xs = ans) true
			[nth_r; nth_i; nth_f; nth_u]))

let prop_findi pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"findi == List.findi" 
	(fun xs -> 
		let ans = snd @@ List.fold_left (fun (ndx, idx) el -> 
			match pred1 el && idx = None with
				| true -> (ndx + 1, Some ndx)
				| _ -> (ndx + 1, idx)) (0, None) xs in
		List.fold_left (fun a f -> a && f pred1 xs = ans) true 
			[findi_r; findi_i; findi_f; findi_u]))

let prop_find pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"find == List.find"
	(fun xs -> 
		let ans = snd @@ List.fold_left (fun (ndx, it) el -> 
			match pred1 el && it = None with
				| true -> (ndx + 1, Some el)
				| _ -> (ndx + 1, it)) (0, None) xs in
		List.fold_left (fun a f -> a && f pred1 xs = ans) true 
			[find_r; find_i; find_f; find_u]))

let prop_min_max arbXs = Q.(Test.make ~count:100 arbXs
	~name:"min_max == (List.min, List.max)"
	(fun xs -> 
		let ansMin = List.fold_left min (List.nth xs 0) xs in
		let ansMax = List.fold_left max (List.nth xs 0) xs in
		List.fold_left (fun a (fMin, fMax) -> a && (fMin xs) = ansMin
			&& (fMax xs) = ansMax) true
			[(min_r, max_r); (min_i, max_i); (min_f, max_f)
            ; (min_u, max_u)]))

let prop_reverse arbXs = Q.(Test.make ~count:100 arbXs
	~name:"reverse == List.rev" 
	(fun xs -> 
		let ans = List.rev xs in
		List.fold_left (fun a f -> a && f xs = ans) true 
			[rev_r; rev_i; rev_f; rev_u]))

let prop_copy arbXs = Q.(Test.make ~count:100 arbXs
	~name:"copy == List.map id"
	(fun xs -> 
		let ans = List.map (fun e -> e) xs in
		List.fold_left (fun a f -> a && f xs = ans) true 
			[copy_r; copy_i; copy_f; copy_u]))

let prop_take_drop arbNXs = Q.(Test.make ~count:100 arbNXs
	~name:"take_drop == (List.take, List.drop)"
	(fun (n, xs) -> 
		let (ansTake, ansDrop) = List.fold_left (fun (aT, aD) _ -> 
			match aD with
				| [] -> (aT, aD)
				| y::ys -> (y :: aT, ys)) ([], xs) (Util.range_cnt n) in
		List.fold_left (fun a (fTake, fDrop) -> a && 
			fTake n xs = List.rev ansTake && fDrop n xs = ansDrop) true
			[(take_i, drop_i); (take_f, drop_f); (take_u, drop_u)]))

let prop_exists_for_all pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"exists_for_all == (List.exists, List.for_all)"
	(fun xs -> 
		let (ansAny, ansAll) = (List.exists pred1 xs, List.for_all pred1 xs) in
		List.fold_left (fun a (fAny, fAll) -> a && (fAny pred1 xs) = ansAny
			&& (fAll pred1 xs) = ansAll) true 
			[(exists_r, for_all_r); (exists_i, for_all_i)
			; (exists_f, for_all_f); (exists_u, for_all_u)]))

let prop_map proc arbXs = Q.(Test.make ~count:100 arbXs
	~name:"map == List.map"
	(fun xs -> 
		let ans = List.map proc xs in
		List.fold_left (fun a f -> a && f proc xs = ans) true 
			[map_r; map_i; map_f; map_u]))

let prop_iter proc arbXs = Q.(Test.make ~count:100 arbXs
	~name:"iter == List.iter"
	(fun xs -> 
		let ans = List.iter proc xs in
		List.fold_left (fun a f -> a && f proc xs = ans) true 
			[iter_r; iter_i; iter_f; iter_u]))

let prop_filter_remove pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"filter_remove == List.partition"
	(fun xs -> 
		let (ansF, ansR) = List.partition pred1 xs in
		List.fold_left (fun a (fnF, fnR) -> a && (fnF pred1 xs) = ansF
			&& (fnR pred1 xs) = ansR) true 
			[(filter_r, remove_r); (filter_i, remove_i)
			; (filter_f, remove_f); (filter_u, remove_u)]))

let prop_fold_left corp init arbXs = Q.(Test.make ~count:100 arbXs
	~name:"fold_left == List.fold_left"
	(fun xs -> 
		let ans = List.fold_left corp init xs in
		List.fold_left (fun a f -> a && f corp init xs = ans) true 
			[fold_left_r; fold_left_i]))

let prop_fold_right proc arbXs init = Q.(Test.make ~count:100 arbXs
	~name:"fold_right == List.fold_right"
	(fun xs -> 
		let ans = List.fold_right proc xs init in
		List.fold_left (fun a f -> a && f proc xs init = ans) true 
			[fold_right_r; fold_right_i]))

let prop_unfold_right func arbSeed = Q.(Test.make ~count:100 arbSeed
	~name:"unfold_right == ?? unfold_right"
	(fun seed -> 
		let ans = _unfold_right_i func seed in
		List.fold_left (fun a f -> a && f func seed = ans) true 
			[unfold_right_i]))

let prop_unfold_left func arbSeed = Q.(Test.make ~count:100 arbSeed
	~name:"unfold_left == ?? unfold_left"
	(fun seed -> 
		let ans = _unfold_left_r func seed in
		List.fold_left (fun a f -> a && f func seed = ans) true 
			[unfold_left_r]))

let prop_isOrdered arbXs = Q.(Test.make ~count:100 arbXs
	~name:"isOrdered == List.for_all (= true) @@ List.fold_left (<=) true"
	(fun xs -> 
		let verifyfn ?(cmpfn = (<=)) keyfn ys = match ys with
			| [] -> true
			| y::ys -> fst @@ List.fold_left (fun (a, cur) e -> 
				((cmpfn cur (keyfn e)) && a, (keyfn e))) (true, y) (y::ys) in
		let ansOrd = verifyfn (fun e -> e) xs in
		let ansRevOrd = verifyfn ~cmpfn:(>=) (fun e -> e) xs in
		List.fold_left (fun a (fnOrd, fnRevOrd) -> a && 
			fnOrd (fun e -> e) xs = ansOrd
			&& fnRevOrd (fun e -> e) xs = ansRevOrd) true 
			[(is_ordered_r ~cmpfn:(<=), is_ordered_r ~cmpfn:(>=))
			; (is_ordered_i ~cmpfn:(<=), is_ordered_i ~cmpfn:(>=))
			; (is_ordered_f ~cmpfn:(<=), is_ordered_f ~cmpfn:(>=))
			; (is_ordered_u ~cmpfn:(<=), is_ordered_u ~cmpfn:(>=))]))

let prop_append arbXsYs = Q.(Test.make ~count:100 arbXsYs
	~name:"append == List.(@)"
	(fun (xs, ys) -> 
		let ans = xs @ ys in
		List.fold_left (fun a f -> a && f xs ys = ans) true
			[append_r; append_i; append_f; append_u]))

let prop_interleave arbXsYs = Q.(Test.make ~count:100 arbXsYs
	~name:"interleave == ??"
	(fun (xs, ys) -> 
		let len_short = match List.length xs < List.length ys with
			| true -> List.length xs | _ -> List.length ys in
		let ans = fst @@ List.fold_right (fun e (a, z::zs) -> (z::e::a, zs))
			(take_i len_short ys) (drop_i len_short xs @ drop_i len_short ys, 
				List.rev (take_i len_short xs)) in
		List.fold_left (fun a f -> a && f xs ys = ans) true
			[interleave_r; interleave_i; interleave_f; interleave_u]))

let prop_map2 proc2 arbXsYs = Q.(Test.make ~count:100 arbXsYs
	~name:"map2 == List.map2"
	(fun (xs, ys) -> 
		let len_short = match List.length xs < List.length ys with
			| true -> List.length xs | _ -> List.length ys in
		let ans = List.map2 proc2 (take_i len_short xs) 
			(take_i len_short ys) in
		List.fold_left (fun a f -> a && f proc2 xs ys = ans) true
			[map2_r; map2_i; map2_f; map2_u]))

let prop_zip arbXsYs = Q.(Test.make ~count:100 arbXsYs
	~name:"zip == List.combine"
	(fun (xs, ys) -> 
		let len_short = match List.length xs < List.length ys with
			| true -> List.length xs | _ -> List.length ys in
		let ans = List.combine (take_i len_short xs) 
			(take_i len_short ys) in
		List.fold_left (fun a f -> a && f xs ys = ans) true
			[zip_r; zip_i; zip_f; zip_u]))

let prop_unzip arbTups = Q.(Test.make ~count:100 arbTups
	~name:"unzip == List.split"
	(fun tups -> 
		let ans = List.split tups in
		List.fold_left (fun a f -> a && f tups = ans) true
			[unzip2_i; unzip2_f; unzip2_u]))

let prop_concat arbNlst = Q.(Test.make ~count:100 arbNlst
	~name:"concat == List.concat"
	(fun nlst -> 
		let ans = List.concat nlst in
		List.fold_left (fun a f -> a && f nlst = ans) true
			[concat_r; concat_i; concat_f; concat_u]))


let prop_unfold_right_range arbInt = 
	let funcRange (start, stop) = match stop < start with
		| true -> None | _ -> Some (start, (start + 1, stop)) in
	prop_unfold_right funcRange Q.(pair (always 0) arbInt)

let prop_unfold_left_fib arbInt = 
	let funcFib (s0, s1, num) = match num < 0 with
		| true -> None | _ -> Some (s0, (s0 + s1, s0, num - 1)) in
	prop_unfold_left funcFib Q.(triple (always 0) (always 1) arbInt)

let prop_unfold_right_base_expand b arbInt = 
	let funcBsExpand num = match num <= 0 with
		| true -> None | _ -> Some (num mod b, num / b) in
	prop_unfold_right funcBsExpand arbInt

let prop_unfold_left_unsum arbInt = 
	let funcUnfoldSum (start, stop) = match stop < start with
		| true -> None | _ -> Some (start, (start + 1, stop - start)) in
	prop_unfold_left funcUnfoldSum Q.(pair (always 0) arbInt)

let prop_unfold_right_unprod arbInt = 
	let funcUnfoldProd (start, stop) = match stop < start with
		(*| true -> None | _ -> Some (start, (start + 1, stop / start)) in*)
		| true -> None | _ -> Some (start, (start * stop, stop - 1)) in
	prop_unfold_left funcUnfoldProd Q.(pair (always 1) arbInt)


(** Suite of test properties
*)
let tprops = OUnit.( >::: ) "Tp_sequenceops" (List.map 
	(QCheck_runner.to_ounit_test ~verbose:true)
	[prop_tabulate (fun i -> i + 2) Q.(0 -- 20)
	; prop_length Q.(list_of_size Gen.(0 -- 20) (0 -- 100))
	; prop_nth Q.(pair (0 -- 19) (list_of_size Gen.(1 -- 20) (0 -- 100)))
	; prop_findi (fun e -> 0 = e mod 2) Q.(list genInts)
	; prop_find (fun e -> 3 = e) Q.(list genInts)
	; prop_min_max Q.(list_of_size Gen.(1 -- 20) (-150 -- 150))
	; prop_reverse Q.(list genInts); prop_copy Q.(list genInts)
	; prop_take_drop Q.(pair (0 -- 20) (list_of_size Gen.(0 -- 20) genInts))
	; prop_exists_for_all (fun e -> 0 = e mod 2) 
		Q.(list_of_size Gen.(0 -- 20) genInts)
	; prop_map (fun e -> e + 2) Q.(list_of_size Gen.(0 -- 20) genInts)
	(*; prop_iter (fun e -> Printf.printf "%d " e) 
		Q.(list_of_size Gen.(0 -- 20) genInts)*)
	; prop_filter_remove (fun e -> 0 = e mod 2) 
		Q.(list_of_size Gen.(0 -- 20) genInts)
	; prop_fold_left (+) 0 Q.(list_of_size Gen.(0 -- 20) genInts)
	; prop_fold_right (-) Q.(list_of_size Gen.(0 -- 20) genInts) 0
	
	; prop_unfold_right_range Q.(0 -- 25); prop_unfold_left_fib Q.(0 -- 25)
	; prop_unfold_right_base_expand 2 Q.(0 -- 1024)
	; prop_unfold_left_unsum Q.(map (fun n ->
		List.fold_left (+) 0 @@ Util.range_cnt n) (0 -- 25))
	; prop_unfold_right_unprod Q.(map (fun n ->
		List.fold_left ( * ) 1 @@ Util.range_cnt ~start:1 n) (1 -- 17))
	
	; prop_isOrdered Q.(list_of_size Gen.(0 -- 24) (-50 -- 50))
	; prop_isOrdered Q.(list_of_size Gen.(0 -- 24) 
		(map Char.chr (Char.code ' ' -- Char.code '~')))
	; prop_append Q.(pair (list_of_size Gen.(0 -- 50) genInts) 
		(list_of_size Gen.(0 -- 50) genInts))
	; prop_interleave Q.(pair (list_of_size Gen.(0 -- 50) genInts) 
		(list_of_size Gen.(0 -- 50) genInts))
	; prop_map2 (fun e1 e2 -> e1 + e2 + 2) Q.(pair 
		(list_of_size Gen.(0 -- 25) genInts) 
		(list_of_size Gen.(0 -- 25) genInts))
	; prop_zip Q.(pair (list_of_size Gen.(0 -- 25) 
		(map Char.chr (Char.code ' ' -- Char.code '~')))
		(list_of_size Gen.(0 -- 25) genInts))
	; prop_unzip Q.(list_of_size Gen.(0 -- 25) (pair 
		(map Char.chr (Char.code ' ' -- Char.code '~')) genInts))
	; prop_concat Q.(list_of_size Gen.(0 -- 19) 
		(list_of_size Gen.(0 -- 10) (0 -- 50)))
	])
