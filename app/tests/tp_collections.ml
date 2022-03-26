(** Collections test properties
*)

module Q = QCheck

let genItems ?f:(f=(fun e -> e)) gen0 = Q.(map f gen0)
let genInts = genItems ~f:(fun n -> n * 2) Q.(-18 -- 10)
let genTup2Items gen0 gen1 = Q.(pair gen0 gen1)


let prop_cons arbXXs = Q.(Test.make ~count:100 arbXXs
	~name:"prop_cons" (fun (x, xs) -> x = List.hd (x :: xs)))

let prop_null arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_null" (fun xs -> (0 = List.length xs) = ([] = xs)))

let prop_equal arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_equal"
	(fun xs ->
		let ys = List.map (fun e -> e) xs in
		fst @@ List.fold_left (fun (a, mss) e -> match mss with
			| [] -> (a, [])
			| m::ms -> (a && m = e, ms)) (true, ys) xs))

let prop_notEqual arbXsYs = Q.(Test.make ~count:100 arbXsYs
	~name:"prop_notEqual"
	(fun (xs, ys) ->
		false = fst @@ List.fold_left (fun (a, mss) e -> match mss with
			| [] -> (false, [])
			| m::ms -> (a && m = e, ms)) (true, xs) ys))

let prop_append arbXsYs = Q.(Test.make ~count:100 arbXsYs
	~name:"prop_append"
	(fun (xs, ys) -> (xs @ ys) =
		List.fold_right (fun e acc -> e :: acc) xs ys))

let prop_revRev arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_reverse" 
	(fun xs -> xs = List.rev @@ List.rev xs))

let prop_filter pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_filter" 
	(fun xs -> List.for_all pred1 @@ List.filter pred1 xs))

let prop_remove pred1 arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_remove" 
	(fun xs -> List.for_all pred1 @@ fst @@ List.partition pred1 xs))

let prop_map f arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_map"
	(fun xs ->
		let ys = List.map f xs in
		fst @@ List.fold_left (fun (a, mss) e -> match mss with
			| [] -> (a, [])
			| m::ms -> (a && m = (f e), ms)) (true, ys) xs))

let rec isOrdered ?(cmpfn = (<=)) xs = match xs with
	| x::y::rst -> cmpfn x y && isOrdered ~cmpfn:cmpfn (y::rst)
	| _ -> true

let prop_sortIsOrdered arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_sortIsOrdered" (fun xs -> isOrdered @@ List.sort compare xs))

let prop_revSortIsRevOrdered arbXs = Q.(Test.make ~count:100 arbXs
	~name:"prop_revSortIsRevOrdered"
	(fun xs -> isOrdered ~cmpfn:(>=) @@ List.rev @@ List.sort compare xs))


(** Suite of test properties
*)
let tprops = OUnit2.( >::: ) "Tp_collections" (List.map 
	(QCheck_runner.to_ounit2_test)
	[prop_cons Q.(pair genInts (list genInts))
	; prop_null Q.(list genInts)
	; prop_equal Q.(list_of_size Gen.(1 -- 20) genInts)
	; prop_notEqual Q.(pair (list_of_size Gen.(1 -- 10) genInts) (list_of_size Gen.(11 -- 20) genInts))
	; prop_append Q.(pair (list genInts) (list genInts))
	; prop_revRev Q.(list genInts)
	; prop_filter (fun e -> 0 = e mod 2) Q.(list genInts)
	; prop_remove (fun e -> 0 = e mod 2) Q.(list genInts)
	; prop_map (fun e -> e + 1) Q.(list_of_size Gen.(1 -- 10) genInts)
	; prop_sortIsOrdered Q.(list genInts)
	; prop_revSortIsRevOrdered Q.(list genInts)
	])
