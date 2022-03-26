(** Sequence Ops test cases
*)

open OUnit2
open Practice.Sequenceops

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ ctx = Printf.printf "... TearDown\n"

let epsilon = 0.001
(* let (lst, revlst) = ([0;1;2;3;4], List.rev [0;1;2;3;4]) *)
let (lst, revlst) = (Util.range_cnt 5, List.rev @@ Util.range_cnt 5)

let test_tabulate _ = List.iter (fun (func_a, cnt) -> 
    assert_equal (Array.to_list @@ Array.init cnt (fun e -> float e))
        (func_a (fun e -> float e) cnt)
    ; assert_equal
        (Array.to_list @@ Array.init cnt (fun e -> 32.0 /. (2.0 ** (float e))))
        (func_a (fun e -> 32.0 /. (2.0 ** (float e))) cnt)
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun n -> (f, n))
    	[3; 5; 7]) [tabulate_r; tabulate_i; tabulate_f; tabulate_u]

let test_length _ = List.iter (fun (func_a, len) -> 
    assert_equal (List.length (Util.range_cnt len)) (func_a (Util.range_cnt len))
    ; assert_equal (List.length (List.rev (Util.range_cnt len)))
        (func_a (List.rev (Util.range_cnt len)))
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun n -> (f, n))
    	[3; 5; 7]) [length_r; length_i; length_f; length_u]

let test_nth _ = List.iter (fun (func_a, xss) ->
    assert_equal (List.nth xss 3) (Util.option_get (-1) (func_a 3 xss))
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [nth_r; nth_i; nth_f; nth_u]

let test_findi _ = 
    let pred = (fun el -> el = 3) in
    List.iter (fun func_a -> 
        assert_equal (Some 3) (func_a pred lst)
        ; assert_equal (Some 1) (func_a pred revlst)
        ) [findi_r; findi_i; findi_f; findi_u]

let test_find _ = 
    let pred = (fun el -> el = 3) in
    List.iter (fun (func_a, xss) -> 
        assert_equal (List.find pred xss) 
            (Util.option_get (-1) (func_a pred xss))
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [find_r; find_i; find_f; find_u]

let test_min_max _ = List.iter (fun (func_tup, xss) ->
    assert_equal 0 ((fst func_tup) xss)
    ; assert_equal 4 ((snd func_tup) xss)
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [(min_r, max_r); (min_i, max_i); (min_f, max_f)
            ; (min_u, max_u)]

let test_rev _ = List.iter (fun (func_a, xss) ->
    assert_equal (List.rev xss) (func_a xss)
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [rev_r; rev_i; rev_f; rev_u]

let test_copy _ = List.iter (fun (func_a, xss) ->
    assert_equal xss (func_a xss)
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [copy_r; copy_i; copy_f; copy_u]

let test_take_drop _ = List.iter (fun (fn_take, fn_drop) ->
    let n = 3 in
    assert_equal [4; 3; 2] (fn_take n revlst)
    ; assert_equal [1; 0] (fn_drop n revlst)
    ) [(take_i, drop_i); (take_f, drop_f); (take_u, drop_u)]

let test_exists_for_all _ = 
    let (pred1, pred2) = ((fun el -> 0 = (el mod 2)), (fun el -> [] <> el)) in
    let (lst1, lst2) = ([1; 2; 3], [[1; 2]; []; [3; 4]]) in
    let (lst3, lst4) = ([6; 2; 4], [[1; 2]; [5]; [3; 4]]) in
    List.iter (fun func_tup -> 
        assert_equal (List.exists pred1 lst1) ((fst func_tup) pred1 lst1)
        ; assert_equal (List.for_all pred1 lst3) ((snd func_tup) pred1 lst3)
        ) [(exists_r, for_all_r); (exists_i, for_all_i); (exists_f, for_all_f)
            ; (exists_u, for_all_u)]
    ; List.iter (fun func_tup ->
        assert_equal (List.exists pred2 lst2) ((fst func_tup) pred2 lst2)
        ; assert_equal (List.for_all pred2 lst4) ((snd func_tup) pred2 lst4)
        ) [(exists_r, for_all_r); (exists_i, for_all_i); (exists_f, for_all_f)
            ; (exists_u, for_all_u)]

let test_map _ =
    let proc = (fun el -> el + 2) in
    List.iter (fun (func_a, xss) -> 
        assert_equal (List.map proc xss) (func_a proc xss)
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [map_r; map_i; map_f; map_u]

let test_iter _ = 
    let proc = (fun el -> Printf.printf "%d " el) in
    List.iter (fun (func_a, xss) -> 
        assert_equal (List.iter proc xss) (func_a proc xss)
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [iter_r; iter_i; iter_f; iter_u]

let test_filter_remove _ =
    let pred = (fun el -> 0 = (el mod 2)) in
    List.iter (fun (fn_filter, xss) -> 
        assert_equal (List.filter pred xss) (fn_filter pred xss) ;
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [filter_r; filter_i; filter_f; filter_u]
    ; List.iter (fun (fn_remove, xss) -> 
        assert_equal (List.filter (fun e -> not @@ pred e) xss) (fn_remove pred xss)
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [remove_r; remove_i; remove_f; remove_u]

let test_fold_left _ = 
    let (corp1, corp2) = ((fun a e -> a + e), (fun a e -> a - e)) in
    List.iter (fun (func_a, xss) -> 
        assert_equal (List.fold_left corp1 0 xss) (func_a corp1 0 xss)
        ; assert_equal (List.fold_left corp2 0 xss) (func_a corp2 0 xss)
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [fold_left_r; fold_left_i]

let test_fold_right _ = 
    let (proc1, proc2) = ((fun e a -> e + a), (fun e a -> e - a)) in
    List.iter (fun (func_a, xss) ->
        assert_equal (List.fold_right proc1 xss 0) (func_a proc1 xss 0)
        ; assert_equal (List.fold_right proc2 xss 0) (func_a proc2 xss 0)
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    		[lst; revlst]) [fold_right_r; fold_right_i]

let test_unfold_right _ =
    assert_equal lst (List.rev (unfold_right_i (fun (h, t) -> match t with
        | 0 -> None | _ -> Some (h, (h + 1, t - h))) (0, 10)))
    ; assert_equal lst (List.rev (unfold_right_i (fun (h, t) -> match t with
        | 0 -> None | _ -> Some (h, (h + 1, t + h))) (0, (-10))))

let test_unfold_left _ =
    assert_equal lst (unfold_left_r (fun (h, t) -> match t with
        | 0 -> None | _ -> Some (h, (h + 1, t - h))) (0, 10))
    ; assert_equal lst (unfold_left_r (fun (h, t) -> match t with
        | 0 -> None | _ -> Some (h, (h + 1, h - t))) (0, 2))

let test_is_ordered _ = 
    let verifyOrder ?(cmpfn = (<=)) keyfn xs = match xs with
        | [] -> true
        | x::xs -> fst @@ List.fold_left (fun (a, cur) e -> 
            ((cmpfn cur (keyfn e)) && a, (keyfn e))) (true, x) (x::xs) in
    List.iter (fun (fnOrd, fnRevOrd) ->
		assert_equal (verifyOrder (fun e -> e) lst) (fnOrd (fun e -> e) lst)
		; assert_equal (verifyOrder ~cmpfn:(>=) (fun e -> e) revlst)
			(fnRevOrd (fun e -> e) revlst)
	) [(is_ordered_r ~cmpfn:(<=), is_ordered_r ~cmpfn:(>=))
		; (is_ordered_i ~cmpfn:(<=), is_ordered_i ~cmpfn:(>=))
		; (is_ordered_f ~cmpfn:(<=), is_ordered_f ~cmpfn:(>=))
		; (is_ordered_u ~cmpfn:(<=), is_ordered_u ~cmpfn:(>=))]
    ; List.iter (fun (fnOrd, fnRevOrd) ->
		assert_equal (verifyOrder (fun e -> e) ['a'; 'c'; 'e'])
			(fnOrd (fun e -> e) ['a'; 'c'; 'e'])
		; assert_equal (verifyOrder ~cmpfn:(>=) (fun e -> e) ['9'; '5'; '2'])
			(fnRevOrd (fun e -> e) ['9'; '5'; '2'])
	) [(is_ordered_r ~cmpfn:(<=), is_ordered_r ~cmpfn:(>=))
		; (is_ordered_i ~cmpfn:(<=), is_ordered_i ~cmpfn:(>=))
		; (is_ordered_f ~cmpfn:(<=), is_ordered_f ~cmpfn:(>=))
		; (is_ordered_u ~cmpfn:(<=), is_ordered_u ~cmpfn:(>=))]

let test_append _ = List.iter (fun (func_a, xss) ->
    assert_equal (xss @ [9; 9; 9; 9]) (func_a xss [9; 9; 9; 9])
    ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [append_r; append_i; append_f; append_u]

let test_interleave _ = 
    let lst2 = [9; 9; 9; 9] in
    List.iter (fun func_a -> 
        assert_equal [0; 9; 1; 9; 2; 9; 3; 9; 4] (func_a lst lst2)
        ) [interleave_r; interleave_i; interleave_f; interleave_u]

let test_map2 _ = 
    let proc = (fun e1 e2 -> (e1 + e2) + 2) in
    List.iter (fun (func_a, xss) ->
        assert_equal (List.map2 proc xss xss) (func_a proc xss xss)
        ) @@ List.flatten @@ List.map (fun f -> List.map (fun l -> (f, l))
    	[lst; revlst]) [map2_r; map2_i; map2_f; map2_u]

let test_zip _ = 
    let (lst1, lst2) = ([0; 1; 2], [20; 30; 40]) in
    List.iter (fun func_a -> 
        assert_equal (List.combine lst1 lst2) (func_a lst1 lst2)
        ) [zip_r; zip_i; zip_f; zip_u]

let test_unzip _ = 
    let lst = [(0, 20); (1, 30)] in
    List.iter (fun func_a -> 
        assert_equal (List.split lst) (func_a lst)
        ) [unzip2_i; unzip2_f; unzip2_u]

let test_concat _ =
    let nlst1 = [[0; 1; 2]; [20; 30]] in
    let nlst2 = [[[0; 1]]; []; [[20; 30]]] in
    List.iter (fun func_a -> 
        assert_equal (List.concat nlst1) (func_a nlst1)
        ) [concat_i; concat_r; concat_f; concat_u]
    ; List.iter (fun func_a -> 
        assert_equal (List.concat nlst2) (func_a nlst2)
        ) [concat_i; concat_r; concat_f; concat_u]


(** Suite of test cases
*)
let tcases = "Tc_sequenceops" >::: (List.map (fun (f, nm) -> 
        (nm >:: (fun ctx -> f @@ bracket set_up tear_down ctx)))
    [(test_tabulate, "test_tabulate"); (test_length, "test_length")
    ; (test_nth, "test_nth"); (test_findi, "test_findi")
    ; (test_find, "test_find"); (test_min_max, "test_min_max")
    ; (test_rev, "test_rev"); (test_copy, "test_copy")
    ; (test_take_drop, "test_take_drop")
    ; (test_exists_for_all, "test_exists_for_all")
    ; (test_map, "test_map"); (test_iter, "test_iter")
    ; (test_filter_remove, "test_filter_remove")
    ; (test_fold_left, "test_fold_left"); (test_fold_right, "test_fold_right")
    ; (test_unfold_right, "test_unfold_right")
    ; (test_unfold_left, "test_unfold_left")
    ; (test_is_ordered, "test_is_ordered")
    ; (test_append, "test_append"); (test_interleave, "test_interleave")
    ; (test_map2, "test_map2"); (test_zip, "test_zip")
    ; (test_unzip, "test_unzip"); (test_concat, "test_concat")
    ])
