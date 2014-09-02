(** Collections test cases
*)

open OUnit

module CharSet = Set.Make(Util.CharOrd)

module StringMap = Map.Make(Util.StringOrd)

module StringHashtbl = Hashtbl.Make(Util.StringHash)

module FloatMinHeap = Batteries.Heap.Make(Util.FloatOrd)

let set_up_class _ = Printf.printf "SetUpClass ...\n"
let tear_down_class _ = Printf.printf "... TearDownClass\n"

let set_up _ = Printf.printf "SetUp ...\n"
let tear_down _ = Printf.printf "... TearDown\n"

let test_lists _ = 
    let lst = [2; 1; 0; 4; 3;] in
    (assert_bool "make-list" (1 :: [] = [1])
    ; assert_bool "equal" (lst = [2; 1; 0; 4; 3;])
    ; assert_bool "inequal" (lst <> [2; 1; 0])
    ; assert_bool "empty" ([] = [])
    ; assert_bool "hd" (List.hd lst = 2)
    ; assert_bool "nth" (List.nth lst 2 = 0)
    ; assert_bool "length" (List.length lst = 5)
    ; assert_bool "append" (lst @ [9; 9; 9; 9;] = [2; 1; 0; 4; 3; 9; 9; 9; 9])
    ; assert_bool "rev" (List.rev lst = [3; 4; 0; 1; 2])
    ; assert_bool "mem" (List.mem 1 lst)
    ; assert_bool "exists" (List.exists (fun x -> 1 = x mod 2) lst)
    ; assert_bool "for_all" (List.for_all (fun x -> 0 = x mod 2) [6; 4; 2])
    ; assert_bool "filter" (List.filter (fun x -> 0 = x mod 2) lst = [2; 0; 4])
    ; assert_bool "remove" (snd (List.partition (fun x -> 0 = x mod 2)
    	lst) = [1; 3])
    ; assert_bool "fold_left" (List.fold_left (fun a e -> a - e) 0 lst = -10)
    ; assert_bool "fold_right" (List.fold_right (fun e a -> e - a) lst 0 = 0)
    ; assert_bool "map" (List.map (fun e -> e + 2) lst = [4; 3; 2; 6; 5;])
    ; assert_bool "to_array" (Array.of_list lst = [|2; 1; 0; 4; 3;|])
    ; assert_bool "sort" (List.sort (fun a b -> compare b a) lst = 
        [4; 3; 2; 1; 0])
    )

let test_1darrays _ = 
    let vec = [|2; 1; 0; 4; 3;|] in
    (assert_bool "make-vector" ([|1|] = Array.of_list [1])
    ; assert_bool "equal" (Array.init 5 (fun x -> x) = [|0; 1; 2; 3; 4|])
    ; assert_bool "inequal" (vec <> [|0; 1; 2; 3; 4|])
    ; assert_bool "empty" ([||] = [||])
    ; assert_bool "get" (Array.get vec 2 = 0)
    ; assert_bool "length" (Array.length vec = 5)
    ; assert_bool "append" (Array.append vec [|9; 9; 9; 9;|] = 
        [|2; 1; 0; 4; 3; 9; 9; 9; 9;|])
    ; assert_bool "fold_left" (Array.fold_left (fun a e -> a - e) 0 vec = -10)
    ; assert_bool "map" (Array.map (fun x -> x + 2) vec = [|4; 3; 2; 6; 5;|])
    ; assert_bool "to_list" (Array.to_list vec = [2; 1; 0; 4; 3;])
    
    ; assert_bool "set" (Array.set vec 0 25 = ())
    ; assert_equal vec [|25; 1; 0; 4; 3;|]
    )

let test_2darrays _ = 
    let arr2d = [|[|0; 1; 2|]; [|3; 4; 5|]|] in
    (assert_bool "make-array" (Array.make_matrix 2 3 0 = 
        [|[|0; 0; 0|]; [|0; 0; 0|]|])
    ; assert_bool "iter" (List.iter (fun i -> (Array.iter (fun x -> 
        Printf.printf "%d " x) (Array.get arr2d i) ; print_newline ())) [0; 1] =
        ())
    ; assert_bool "set" (Array.set arr2d.(0) 2 3 = ())
    ; assert_bool "iter" (List.iter (fun i -> (Array.iter (fun x -> 
        Printf.printf "%d " x) arr2d.(i) ; print_newline ())) [0; 1] =
        ())
    )

let test_alists _ = 
    let lst_str = ["ltr 0";"ltr 1";"ltr 2";"ltr 3";"ltr 4";"ltr 5";"ltr 6"] in
    let lst_char = ['a'; 'e'; 'k'; 'p'; 'u'; 'k'; 'a'] in
    let alst = List.combine lst_str lst_char in
    (assert_bool "make-alist" (List.combine lst_str lst_char = alst)
    ; assert_bool "assoc" (List.assoc "ltr 1" alst <> 'b')
    ; assert_bool "mem_assoc" (List.mem_assoc "ltr 2" alst)
    ; assert_bool "remove_assoc" (List.remove_assoc "ltr 0" alst = 
        [("ltr 1", 'e'); ("ltr 2", 'k'); ("ltr 3", 'p'); ("ltr 4", 'u')
        ; ("ltr 5", 'k'); ("ltr 6", 'a')])
    )

let test_sets _ = 
    let (char_set, set2) = (ref CharSet.empty, ref CharSet.empty) in
    let lst = ['a'; 'e'; 'k'; 'p'; 'u'; 'k'; 'a'] in
    let sort_res set1 = List.sort compare (CharSet.elements set1) in
    let xor_set setA setB = 
        let set_union = (CharSet.union setA setB) in
        let set_inter = CharSet.inter setA setB in
        CharSet.diff set_union set_inter in
    (assert_bool "make-set" (CharSet.empty = !char_set)
    ; List.iter (fun e -> (char_set := CharSet.add e !char_set ; ())) lst
    ; List.iter (fun e -> (set2 := CharSet.add e !set2 ; ())) 
        ['q'; 'p'; 'z'; 'u']
    ; assert_bool "adjoin" (let _ = CharSet.add 'i' !char_set in true)
    ; assert_bool "union" (sort_res (CharSet.union !char_set !set2) = 
        ['a'; 'e'; 'k'; 'p'; 'q'; 'u'; 'z'])
	; assert_bool "intersection" (sort_res (CharSet.inter !char_set !set2) = 
        ['p'; 'u'])
    ; assert_bool "difference" (sort_res (CharSet.diff !char_set !set2) = 
        ['a'; 'e'; 'k'])
    ; assert_bool "xor" (sort_res (xor_set !char_set !set2) = 
        ['a'; 'e'; 'k'; 'q'; 'z'])
    ; assert_bool "to_list" (sort_res !char_set = ['a'; 'e'; 'k'; 'p'; 'u'])
    )

let test_maps _ = 
    let str_map = ref StringMap.empty in
    let lst_str = ["ltr 0";"ltr 1";"ltr 2";"ltr 3";"ltr 4";"ltr 5";"ltr 6"] in
    let lst_char = ['a'; 'e'; 'k'; 'p'; 'u'; 'k'; 'a'] in
    (assert_bool "make-map" (let _ = StringMap.empty in true)
    ; assert_bool "empty" (StringMap.is_empty !str_map)
    ; List.iter (fun (k, v) -> (str_map := StringMap.add k v !str_map ; ()))
        (List.combine lst_str lst_char)
    ; assert_bool "add" (let _ = StringMap.add "ltr 20" 'Z' !str_map in true)
    ; assert_bool "find" (StringMap.find "ltr 1" !str_map <> 'b')
    ; assert_bool "remove" (let _ = StringMap.remove "ltr 1" !str_map in true)
    ; assert_bool "length" (StringMap.fold (fun _ _ a -> a + 1) !str_map 0 = 7)
    ; assert_bool "to_alist" (StringMap.bindings !str_map = [("ltr 0", 'a')
    	; ("ltr 1", 'e'); ("ltr 2", 'k'); ("ltr 3", 'p'); ("ltr 4", 'u')
        ; ("ltr 5", 'k'); ("ltr 6", 'a')])
    )

let test_hashtbls _ = 
    let str_htbl = StringHashtbl.create 10 in
    let lst_str = ["ltr 0";"ltr 1";"ltr 2";"ltr 3";"ltr 4";"ltr 5";"ltr 6"] in
    let lst_char = ['a'; 'e'; 'k'; 'p'; 'u'; 'k'; 'a'] in
    (assert_bool "make-hashtbl" (let _ = StringHashtbl.create 10 in true)
    ; List.iter (fun (k, v) -> (StringHashtbl.replace str_htbl k v 
        ; ())) (List.combine lst_str lst_char)
    ; assert_bool "length" (StringHashtbl.length str_htbl = 7)
    ; assert_bool "find" (StringHashtbl.find str_htbl "ltr 1" <> 'b')
    ; assert_bool "mem" (StringHashtbl.mem str_htbl "ltr 1")
    ; assert_bool "to_alist" (List.sort (fun (a, _) (b, _) -> compare a b)
    	(StringHashtbl.fold (fun k v a -> (k, v) :: a)
        str_htbl []) = [("ltr 0", 'a'); ("ltr 1", 'e'); ("ltr 2", 'k')
        	; ("ltr 3", 'p'); ("ltr 4", 'u'); ("ltr 5", 'k'); ("ltr 6", 'a')])
    
    ; assert_bool "remove" (StringHashtbl.remove str_htbl "ltr 0" ; true)
    ; assert_bool "mem" ((StringHashtbl.mem str_htbl "ltr 0") = false)
    ; assert_bool "replace" (StringHashtbl.replace str_htbl "ltr 0" 'M' ; true)
    ; assert_bool "find" (StringHashtbl.find str_htbl "ltr 0" = 'M')
    )

let test_queues _ = 
    let (queue, lst) = (Queue.create (), [25.7; 0.1; 78.5; 52.3]) in
    let queue2 = Util.queue_ofList lst in
    (assert_bool "make-queue" (Queue.create () = queue)
    ; List.iter (fun e -> Queue.add e queue) lst
    ; assert_bool "of_list" (let _ = Util.queue_ofList lst in true)
    ; assert_bool "empty" (Queue.is_empty queue = false)
    ; assert_bool "peek" (Queue.peek queue = 25.7)
    ; assert_bool "enqueue" (Queue.add (-5.0) queue = ())
    ; assert_bool "dequeue" (Queue.take queue = 25.7)
    ; assert_bool "to_list" ((Util.queue_toList queue) = 
        [0.1; 78.5; 52.3; -5.0])
    ; assert_bool "to_list q2" ((Util.queue_toList queue2) = lst)
    )

let test_heaps _ = 
    let (heap_min, lst) = (ref FloatMinHeap.empty, [25.7; 0.1; 78.5; 52.3]) in
    (List.iter (fun e -> (heap_min := FloatMinHeap.add e !heap_min ; ())) lst
    ; assert_bool "make-heap" (let _ = FloatMinHeap.empty in true)
    ; assert_bool "size" (FloatMinHeap.size !heap_min = 4)
    ; assert_bool "add" (heap_min := FloatMinHeap.add (-5.0) !heap_min ; true)
    ; assert_bool "extract" (heap_min := FloatMinHeap.del_min !heap_min ; true)
    ; assert_bool "top" (FloatMinHeap.find_min !heap_min = 0.1)
    ; assert_bool "to_list" (FloatMinHeap.to_list !heap_min = 
        [0.1; 25.7; 52.3; 78.5])
    )

(** Suite of test cases
*)
let tcases = "Tc_collections" >::: (List.map (fun (f, nm) -> 
        (nm >:: (bracket set_up f tear_down)))
    [(test_lists, "test_lists"); (test_1darrays, "test_1darrays")
    ; (test_2darrays, "test_2darrays"); (test_alists, "test_alists")
    ; (test_sets, "test_sets"); (test_maps, "test_maps")
    ; (test_hashtbls, "test_hashtbls"); (test_queues, "test_queues")
    ; (test_heaps, "test_heaps")
    ])

