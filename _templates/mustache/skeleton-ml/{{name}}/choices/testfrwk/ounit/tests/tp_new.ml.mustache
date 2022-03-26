(** Example test properties
*)

module Q = QCheck

let genItems ?f:(f=(fun e -> e)) gen0 = Q.(map f gen0)
(*let genInts = genItems ~f:(fun n -> n * 2) Q.small_int*)
let genInts = genItems ~f:(fun n -> n * 2) Q.(-18 -- 10)
let genFlts = genItems Q.(map float_of_int (0 -- 500))
let genTup2Items gen0 gen1 = Q.(pair gen0 gen1)
let genTup3Items gen0 gen1 gen2 = Q.(triple gen0 gen1 gen2)


let prop_commutative ~op x y = op x y = op y x
let prop_associative ~op x y z = op (op x y) z = op x (op y z)

let prop_revRev arbXs = Q.(Test.make ~count:100 arbXs
	~name:"id == reverse @@ reverse" 
	(fun xs -> xs = List.rev @@ List.rev xs))

let prop_revId arbXs = Q.(Test.make ~count:100 arbXs
	~name:"id == reverse" (fun xs -> xs = List.rev xs))

let prop_sortRev arbXs = Q.(Test.make ~count:100 arbXs
	~name:"sort == sort @@ reverse" 
	(fun xs -> List.sort compare xs = List.sort compare @@ List.rev xs))

let prop_sortMin arbXs = Q.(Test.make ~count:100 arbXs
	~name:"minimum == head @@ sort" 
	(fun xs -> List.fold_left min (List.nth xs 0) xs = 
		List.hd @@ List.sort compare xs))

let prop_sortMinAppend arbXsYs = Q.(Test.make ~count:100 arbXsYs 
	~name:"minimum == head @@ sort @@ (@)"
	(fun (xs, ys) -> min (List.fold_left min (List.nth xs 0) xs) 
		(List.fold_left min (List.nth ys 0) ys) = 
		List.hd @@ List.sort compare (xs @ ys)))

let prop_commutAddInts = Q.(Test.make ~count:100 (genTup2Items genInts genInts)
	~name:"+ is commutAddInts" (fun (x, y) -> prop_commutative ~op:(+) x y))

let prop_assocAddInts = Q.(Test.make ~count:100 
	(genTup3Items genInts genInts genInts)
	~name:"+ is assocAddInts" 
	(fun (x, y, z) -> prop_associative ~op:(+) x y z))

let prop_commutAddFlts = Q.(Test.make ~count:100 (genTup2Items genFlts genFlts)
	~name:"+ is commutAddFlts" (fun (x, y) -> prop_commutative ~op:(+.) x y))

let prop_assocAddFlts = Q.(Test.make ~count:100 
	(genTup3Items genFlts genFlts genFlts)
	~name:"+ is assocAddFlts" 
	(fun (x, y, z) -> prop_associative ~op:(+.) x y z))


(** Suite of test properties
*)
(*let tprops = QCheck_runner.( >::: ) "Tp_new"
	[prop_commutAddInts; prop_assocAddInts
	]*)
let tprops = OUnit2.( >::: ) "Tp_new" (List.map 
	(QCheck_runner.to_ounit2_test)
	[prop_commutAddInts; prop_assocAddInts; prop_commutAddFlts
	; prop_assocAddFlts; prop_revRev Q.(list genInts)
	; prop_revId Q.(list genInts)
	; prop_sortRev Q.(list (map Char.chr (Char.code ' ' -- Char.code '~')))
	; prop_sortMin Q.(list_of_size Gen.(1 -- 20) genInts)
	; prop_sortMinAppend (genTup2Items Q.(list_of_size Gen.(1 -- 20) genInts) 
		Q.(list_of_size Gen.(1 -- 20) genInts))
	])
