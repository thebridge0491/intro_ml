let tabulate_f func cnt = List.rev @@
    List.fold_left (fun a i -> func i :: a) [] (Util.range_cnt cnt)

let length_f xss = List.fold_left (fun acc _ -> acc + 1) 0 xss

let nth_f idx xss = snd @@ List.fold_left 
    (fun (h, t) e -> (h + 1, if idx = h then Some e else t)) (0, None) xss

let index_find_f ?(ndx = 0) pred xss =
    let corp (ndx1, (idx, it)) el = match pred el && it = None with
        | true -> (ndx1 + 1, (Some ndx1, Some el))
        | _ -> (ndx1 + 1, (idx, it))
in snd @@ List.fold_left corp (ndx, (None, None)) xss

let findi_f pred xss = fst @@ index_find_f pred xss

let find_f pred xss = snd @@ index_find_f pred xss

let minmax_f xss = match xss with
    | [] -> raise (Failure "empty list")
    | x::xs -> List.fold_left (fun (lo, hi) e -> match (e < lo, e > hi) with
            | (true, _) -> (e, hi)
            | (_, true) -> (lo, e)
            | (_, _) -> (lo, hi)
        ) (x, x) xs

let min_f xss = match (minmax_f xss) with lo, _ -> lo

let max_f xss = match (minmax_f xss) with _, hi -> hi

let rev_f xss = List.fold_left (fun acc el -> el :: acc) [] xss

let copy_f xss = List.fold_right (fun el acc -> el :: acc) xss []

let splitn_f n xss =
    List.fold_left (fun (t, ys) _ -> match ys with
        | [] -> (t, ys)
        | z::zs -> (z :: t, zs)
        ) ([], xss) (Util.range_cnt n)

let take_f n xss = List.rev @@ fst @@ splitn_f n xss

let drop_f n xss = snd @@ splitn_f n xss

let exists_for_all_f pred xss = List.fold_left
    (fun (m, n) e -> (m || pred e, n && pred e)) (false, true) xss

let exists_f pred xss = fst @@ exists_for_all_f pred xss

let for_all_f pred xss = snd @@ exists_for_all_f pred xss

let map_f proc xss = List.fold_right (fun el acc -> (proc el)::acc) xss []

let iter_f proc xss = List.fold_left (fun _ el -> proc el) () xss

let partition_f pred xss = List.fold_left 
    (fun (f, r) e -> if pred e then (e :: f, r) else (f, e :: r))
    ([], []) (List.rev xss)

let filter_f pred xss = fst @@ partition_f pred xss

let remove_f pred xss = snd @@ partition_f pred xss

let is_ordered_f ?(cmpfn = (<=)) keyfn xss = match xss with
    | [] -> true
    | x::xs -> snd @@
        List.fold_left (fun (oldval, acc) e -> (e, acc && cmpfn (keyfn oldval)
            (keyfn e))) (x, true) xs

let append_f xss yss = List.fold_right (fun el acc -> el::acc) xss yss

let interleave_f xss yss = 
    let len_short = match List.length xss < List.length yss with
        | true -> List.length xss | _ -> List.length yss
in fst @@ List.fold_right (fun e (a, z::zs) -> (z::e::a, zs))
    (take_f len_short yss) (drop_f len_short xss @ drop_f len_short yss, 
        List.rev (take_f len_short xss))

let map2_f proc xss yss = 
    let len_short = match List.length xss < List.length yss with
        | true -> List.length xss | _ -> List.length yss
in List.rev @@ fst @@ List.fold_left (fun (a, (x::xs, y::ys)) _ ->
    (proc x y :: a, (xs, ys)))
    ([], (xss, yss)) (Util.range_cnt len_short)

let zip_f xss yss = map2_f (fun el1 el2 -> (el1, el2)) xss yss

let unzip2_f xss = List.fold_right
    (fun (eh, et) (ah, at) -> (eh :: ah, et :: at)) xss ([], [])

let concat_f nlsts = List.fold_right (fun e a -> e @ a) nlsts []


let unfold_right_i func seed =
    let rec iter cur acc = match func cur with
        | None -> acc | Some (a, new_cur) -> iter new_cur (a :: acc)
in iter seed []

let rec unfold_left_r func seed = match func seed with
    | None -> [] | Some (a, new_seed) -> a :: unfold_left_r func new_seed

let tabulate_u func cnt = 
    let res = unfold_right_i (fun (i, a) -> match cnt <= i with
        | true -> None | _ -> Some (func i :: a, (i + 1, func i :: a))) (0, [])
in match res with | [] -> [] | x::_ -> List.rev x

let length_u xss = 
    let res = unfold_right_i (fun (h, t) -> match t with
        | [] -> None | _::xs -> Some (h + 1, (h + 1, xs))) (0, xss)
in match res with | [] -> 0 | x::_ -> x

let nth_u idx xss = 
    let res = unfold_right_i (fun (i, e, l) -> match l with
        | [] -> None | x::xs ->
			let res = if idx = i then Some x else e in
            Some (res, (i + 1, res, xs))) (0, None, xss)
in match res with | [] -> None | x::_ -> x

let index_find_u ?(ndx = 0) pred xss = 
    let fn z (idx, el) n = match pred z && el = None with
        | true -> (Some n, Some z) | _ -> (idx, el) in
    let res = unfold_right_i (fun (n, a, l) -> match (n, a, l) with
        | (_, _, []) -> None | (n, a, x::xs) -> 
            Some (fn x a n, (n + 1, fn x a n, xs))) (ndx, (None, None), xss)
in match res with | [] -> (None, None) | x::_ -> x

let findi_u pred xss = fst @@ index_find_u pred xss

let find_u pred xss = snd @@ index_find_u pred xss

let minmax_u xss = match xss with
    | [] -> raise (Failure "empty list")
    | x::xs -> 
        let fn z (lo, hi) = match (z < lo, z > hi) with
            | (true, _) -> (z, hi) | (_, true) -> (lo, z) | _ -> (lo, hi) in
        let res = unfold_right_i (fun (a, yss) -> match yss with
            | [] -> None | y::ys -> Some (fn y a, (fn y a, ys))) ((x, x), xs)
    in match res with | [] -> (x, x) | w::_ -> w

let min_u xss = match (minmax_u xss) with lo, _ -> lo

let max_u xss = match (minmax_u xss) with _, hi -> hi

let rev_u xss = unfold_right_i (fun t -> match t with
        | [] -> None | x::xs -> Some (x, xs)) xss

let copy_u xss = unfold_left_r (fun t -> match t with
        | [] -> None | x::xs -> Some (x, xs)) xss

let splitn_u n xss =
    let res = unfold_right_i (fun (ct, (t, d)) -> match (ct, d) with
        | (0, _) -> None | (_, []) -> None | (_, x::xs) -> 
            Some ((x :: t, xs), (ct - 1, (x :: t, xs)))) (n, ([], xss))
in match res with | [] -> ([], xss) | x::_ -> x

let take_u n xss = List.rev @@ fst @@ splitn_u n xss

let drop_u n xss = snd @@ splitn_u n xss

let exists_for_all_u pred xss = 
    let res = unfold_right_i (fun ((e, a), l) -> match l with
        | [] -> None | x::xs -> 
			let (resE, resA) = (e || pred x, a && pred x) in
            Some ((resE, resA), ((resE, resA), xs))) ((false, true), xss)
in match res with | [] -> (false, true) | x::_ -> x

let exists_u pred xss = fst @@ exists_for_all_u pred xss

let for_all_u pred xss = snd @@ exists_for_all_u pred xss

let map_u proc xss = unfold_left_r (fun t -> match t with
        | [] -> None | x::xs -> Some (proc x, xs)) xss

let iter_u proc xss = 
    let res = unfold_right_i (fun t -> match t with
        | [] -> None | x::xs -> Some (proc x ; (), xs)) xss
in match res with | [] -> () | x::_ -> x

let partition_u pred xss =
    let res = unfold_right_i (fun ((f, r), t) -> match t with
        | [] -> None | x::xs -> match pred x with
            | true -> Some ((x::f, r), ((x::f, r), xs))
            | _ -> Some ((f, x::r), ((f, x::r), xs))) (([], []), List.rev xss)
in match res with | [] -> ([], []) | x::_ -> x

let filter_u pred xss = fst @@ partition_u pred xss

let remove_u pred xss = snd @@ partition_u pred xss

let is_ordered_u ?(cmpfn = (<=)) keyfn xss = match xss with
    | [] -> true
    | x::xs ->
        let fn el oldval = cmpfn (keyfn oldval) (keyfn el) in
        let res = unfold_right_i (fun (a, o, l) -> match l with
            | [] -> None | y::ys -> Some (a && fn y o, (a && fn y o, y, ys)))
            (true, x, xs)
    in match res with | [] -> true | r::_ -> r

let append_u xss yss = 
    let res = unfold_right_i (fun (h, t) -> match t with
        | [] -> None | x::xs -> Some (x::h, (x::h, xs))) (yss, List.rev xss)
in match res with | [] -> yss | x::_ -> x

let interleave_u xss yss = 
    let res = unfold_right_i (fun (wss, zss) -> match (wss, zss) with
        | ([], [])  -> None | ([], z::zs) -> Some (z, (zs, [])) 
        | (w::ws, zs) -> Some (w, (zs, ws))) (xss, yss)
in match res with | [] -> yss | x -> List.rev x

let map2_u proc xss yss = 
    let res = unfold_right_i (fun (h, t) -> match (h, t) with
        | ([], _) -> None | (_, []) -> None
        | (x::xs, y::ys) -> Some (proc x y, (xs, ys))) (xss, yss)
in match res with | [] -> [] | x -> List.rev x

let zip_u xss yss = map2_u (fun el1 el2 -> (el1, el2)) xss yss

let unzip2_u xss = 
    let res = unfold_right_i (fun ((h, t), l) -> match ((h, t), l) with
        | ((_, _), []) -> None
        | ((ws, zs), (w, z)::us) -> Some ((w::ws, z::zs), ((w::ws, z::zs), us))) (([], []), List.rev xss)
in match res with | [] -> ([], []) | x::_ -> x

let concat_u xss = 
    let res = unfold_right_i (fun (h, t) -> match t with
        | [] -> None | x::xs -> Some (x @ h, (x @ h, xs))) ([], List.rev xss)
in match res with | [] -> [] | x::_ -> x
