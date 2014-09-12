(*open! Practice*)

let tabulate_i func cnt =
    let rec iter idx acc = match (1 > idx) with
        | true -> acc
        | _ -> iter (idx - 1) ((func (idx - 1))::acc)
in iter cnt []

let rec tabulate_r func cnt = match (1 > cnt) with
    | true -> []
    | _ -> (tabulate_r func (cnt - 1)) @ [(func (cnt - 1))]

let length_i xss = 
    let rec iter acc rst = match rst with
        |   [] -> acc
        |   _::xs -> iter (acc + 1) xs
in iter 0 xss

let rec length_r xss = match xss with
    |   [] -> 0 
    |   _::xs -> 1 + (length_r xs)

let nth_i idx xss = 
    let rec iter ndx rst = match rst with
        |   [] -> None
        |   x::xs -> match ndx with
            |   0 -> Some x
            |   _ -> iter (ndx - 1) xs
in iter idx xss

let rec nth_r idx xss = match xss with
    |   [] -> None
    |   x::xs -> match idx with
        |   0 -> Some x
        |   _ -> nth_r (idx - 1) xs

let index_find_i ?(ndx = 0) pred xss =
    let rec iter idx rst = match rst with
        | [] -> (None, None)
        | x::xs -> match pred x with
            | true -> (Some idx, Some x)
            | _ -> iter (idx + 1) xs
in iter ndx xss

let rec index_find_r ?(ndx = 0) pred xss = match xss with
    | [] -> (None, None)
    | x::xs -> match pred x with
        | true -> (Some ndx, Some x)
        | _ -> index_find_r ~ndx:(ndx + 1) pred xs

let findi_i pred xss = fst @@ index_find_i pred xss
let findi_r pred xss = fst @@ index_find_r pred xss

let find_i pred xss = snd @@ index_find_i pred xss
let find_r pred xss = snd @@ index_find_r pred xss

let minmax_i [] = raise (Failure "empty list")
let minmax_i (x::xs) = 
    let rec iter (lo, hi) rst = match rst with
        | [] -> (lo, hi)
        | y::ys -> match (y < lo, y > hi) with
            | (true, _) -> iter (y, hi) ys
            | (_, true) -> iter (lo, y) ys
            | (_, _) -> iter (lo, hi) ys
in iter (x, x) xs

let minmax_r xss = 
    let rec _helper_r norm rst = match rst with
        | [] -> raise (Failure "empty list")
        | x::[] -> x
        | x::y::zs -> match (norm (x < y)) with
            | true -> _helper_r norm (x::zs)
            | _ -> _helper_r norm (y::zs)
in (_helper_r (fun e -> e) xss, _helper_r not xss)

let min_i xss = match (minmax_i xss) with lo, _ -> lo
let min_r xss = match (minmax_r xss) with lo, _ -> lo

let max_i xss = match (minmax_i xss) with _, hi -> hi
let max_r xss = match (minmax_r xss) with _, hi -> hi

let rev_i xss = 
    Bolt.Logger.log "prac" Bolt.Level.DEBUG "rev_i()";
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> iter xs (x:: acc)
in iter xss []

let rec rev_r xss = match xss with
    |   [] -> []
    |   x::xs -> (rev_r xs) @ [x]

let copy_i xss = 
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> iter xs (x :: acc)
in iter (List.rev xss) []

let rec copy_r xss = match xss with
    |   [] -> []
    |   x::xs -> x:: (copy_r xs)

let splitn_i n xss =
    let rec iter m rst acc = match rst with
        |   [] -> (List.rev acc, [])
        |   x::xs -> match m with
            |   0 -> (List.rev acc, rst)
            |   _ -> iter (m - 1) xs (x :: acc)
in iter n xss []

let take_i n xss = fst (splitn_i n xss)

let drop_i n xss = snd (splitn_i n xss)

let exists_for_all_i pred xss = 
    let rec iter norm rst = match rst with
        |   [] -> norm false
        |   x::xs -> match norm (pred x) with
            |   true -> norm true
            |   _ -> iter norm xs
in (iter (fun e -> e) xss, iter not xss)

let exists_for_all_r pred xss = 
    let rec _helper_r norm rst = match rst with
        |   [] -> norm false
        |   x::xs -> match norm (pred x) with
            |   true -> norm true
            |   _ -> _helper_r norm xs
in (_helper_r (fun e -> e) xss, _helper_r not xss)

let exists_i pred xss = fst @@ exists_for_all_i pred xss
let exists_r pred xss = fst @@ exists_for_all_r pred xss

let for_all_i pred xss = snd @@ exists_for_all_i pred xss
let for_all_r pred xss = snd @@ exists_for_all_r pred xss

let map_i proc xss = 
    let rec iter rst acc = match rst with
    |   [] -> acc
    |   x::xs -> iter xs ((proc x) :: acc)
in iter (List.rev xss) []

let rec map_r proc xss = match xss with
    |   [] -> []
    |   x::xs -> (proc x) :: (map_r proc xs)

let iter_i proc xss = 
    let rec iter rst = match rst with
        |   [] -> ()
        |   x::xs -> ((proc x) ; iter xs)
in iter xss

let rec iter_r proc xss = match xss with
    |   [] -> ()
    |   x::xs -> ((proc x) ; iter_r proc xs)

let partition_i pred xss = 
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> match pred x with
            |   true -> iter xs (x :: (fst acc), snd acc)
            |   _ -> iter xs (fst acc, x :: (snd acc))
in iter (List.rev xss) ([], [])

let partition_r pred xss = 
    let rec _helper_r norm rst = match rst with
        | [] -> []
        | x::xs -> match norm (pred x) with
            | true -> x :: (_helper_r norm xs)
            | _ -> _helper_r norm xs
in (_helper_r (fun e -> e) xss, _helper_r not xss)

let filter_i pred xss = fst (partition_i pred xss)
let filter_r pred xss = fst @@ partition_r pred xss

let remove_i pred xss = snd (partition_i pred xss)
let remove_r pred xss = snd @@ partition_r pred xss

let fold_left_i corp init xss = 
    let rec iter acc rst = match rst with
        |   [] -> acc
        |   x::xs -> iter (corp acc x) xs
in iter init xss

let rec fold_left_r corp init xss = match xss with
    |   [] -> init
    |   x::xs -> fold_left_r corp (corp init x) xs

let fold_right_i proc xss init = 
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> iter xs (proc x acc)
in iter (List.rev xss) init

let rec fold_right_r proc xss init = match xss with
    |   [] -> init
    |   x::xs -> proc x (fold_right_r proc xs init)

(*
let unfold_right0_i pred func gen seed = 
    let rec iter cur acc = match pred cur with
        |   true -> acc
        |   _ -> iter (gen cur) ((func cur) :: acc)
in iter seed []

let rec unfold_left0_r pred func gen seed = match pred seed with
    |   true -> []
    |   _ -> (func seed) :: (unfold_left0_r pred func gen (gen seed))
*)
let unfold_right_i func seed =
    let rec iter cur acc = match func cur with
        | None -> acc | Some (a, new_cur) -> iter new_cur (a :: acc)
in iter seed []

let rec unfold_left_r func seed = match func seed with
    | None -> [] | Some (a, new_seed) -> a :: unfold_left_r func new_seed

let is_ordered_i ?(cmpfn = (<=)) keyfn xss = match xss with
	| [] -> true
	| x::xs ->
		let rec iter rst oldval acc = match rst with
			| [] -> acc
			| y::ys -> iter ys y ((cmpfn (keyfn oldval) (keyfn y)) && acc)
		in iter xs x true

let rec is_ordered_r ?(cmpfn = (<=)) keyfn xs = match xs with
    | [] -> true
    | [_] -> true
    | y::z::zs -> (cmpfn (keyfn y) (keyfn z)) && 
        (is_ordered_r ~cmpfn:cmpfn keyfn (z::zs))

let append_i xss yss = 
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> iter xs (x :: acc)
in iter (List.rev xss) yss

let rec append_r xss yss = match xss with
    |   [] -> yss
    |   x::xs -> x :: (append_r xs yss)

let interleave_i xss yss =
    let rec iter rst1 rst2 acc = match (rst1, rst2) with
        |   ([], _) -> (List.rev acc) @ rst2
        |   (_, []) -> (List.rev acc) @ rst1
        |   (x::xs, y::ys) -> iter xs ys (y :: x :: acc)
in iter xss yss []

let rec interleave_r xss yss = match (xss, yss) with
    |   ([], _) -> yss
    |   (_, []) -> xss
    |   (x::xs, _) -> x :: (interleave_r yss xs)

let map2_i proc xss yss = 
    let rec iter wss zss acc = match (wss, zss) with
        | ([], _) -> acc
        | (_, []) -> acc
        | (x::xs, y::ys) -> iter xs ys (acc @ [proc x y])
in iter xss yss []

let rec map2_r proc xss yss = match (xss, yss) with
    |   ([], _) -> []
    |   (_, []) -> []
    |   (x::xs, y::ys) -> (proc x y) :: (map2_r proc xs ys)

let zip_i xss yss = map2_i (fun el1 el2 -> (el1, el2)) xss yss
let zip_r xss yss = map2_r (fun el1 el2 -> (el1, el2)) xss yss

let unzip2_i xss = 
    let rec iter rst acc = match rst with
        |   [] -> acc
        |   x::xs -> iter xs (fst x :: fst acc, snd x :: snd acc)
in iter (List.rev xss) ([], []) 

let concat_i nlsts = match nlsts with
    |   [] -> []
    |   hd::tl ->
        let rec iter acc rst = match rst with
            |   [] -> List.rev acc
            |   x::xs -> iter ((List.rev x) @ acc) xs
    in iter (List.rev hd) tl

let rec concat_r nlsts = match nlsts with
    | [] -> []
    | x::xs -> x @ (concat_r xs)
