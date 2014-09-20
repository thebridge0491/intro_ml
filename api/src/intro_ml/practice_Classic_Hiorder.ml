module Sequenceops = Practice_Sequenceops

let expt_f b n =
    List.fold_left (fun a _ -> a *. b) 1.0 (Util.range_cnt ~start:1 @@ 
		truncate n)

let square_f n = expt_f n 2.0

let numseq_math_f ?(init = 0L) op hi lo =
	match hi >= lo with
		| true -> List.fold_left op init @@
			List.map Int64.of_int (Util.range_cnt ~start:(Int64.to_int lo) 
				@@ Int64.to_int hi - Int64.to_int lo + 1)
		| _ -> init

let sum_to_f hi lo = numseq_math_f Int64.add hi lo

let fact_f n = numseq_math_f ~init:1L Int64.mul n 1L

let fib_f n = snd @@
    List.fold_left (fun (s0, s1) _ -> (s0 + s1, s0)) (0, 1)
        (Util.range_cnt (n + 1))

let pascaltri_f rows = List.rev @@
    List.fold_left (fun (x::xs) _ -> (List.map2 (fun a b -> a + b)
        (0::x) (x @ [0])) :: (x::xs)) [[1]] (Util.range_cnt ~start:1 rows)

let _euclid m n = 
    let rec iter a b = match b with | 0 -> a | _ -> iter b (a mod b)
in iter m n

let gcd_f xss = match xss with
    | [] -> 0 | x::xs -> List.fold_left _euclid x xs

let lcm_f xss = match xss with
    | [] -> 0
    | x::xs -> List.fold_left (fun a b -> (a * b) / (_euclid a b)) x xs

let base_expand_f b n = fst @@
    List.fold_left (fun (acc, num) _ -> match num with
        | 0 -> (acc, num / b)
        | _ -> (num mod b :: acc, num / b))
        ([], n) (Util.range_cnt ((truncate @@ log (float n) /. log (float b)) + 1))

let base_to10_f b xss = 
    let proc e (h, t) = (h + 1, t + (e * (truncate @@ (float b ** float h))))
in snd @@ List.fold_right proc xss (0, 0)

let range_step_f ?(step = 1) ?(start = 0) stop = 
    let cmp_op = if step > 0 then (>) else (<) in
    let cnt = match step > 0 with
        | true -> (abs (stop - start)) + 1
        | _ -> (abs (start - stop)) + 1
in List.rev @@ List.fold_left (fun xss e -> 
    match cmp_op ((e * step) + start) stop with
    | true -> xss | _ -> ((e * step) + start) :: xss) [] (Util.range_cnt cnt)

let range_f start stop = range_step_f ~start:start stop


let expt_u b n =
    let res = Sequenceops.unfold_right_i (fun (h, t) -> match 0.0 >= t with
        | true -> None | _ -> Some (h *. b, (h *. b, t -. 1.0))) (1.0, n)
in match res with | [] -> b | x::_ -> x

let square_u n = expt_u n 2.0

let numseq_math_u ?(init = 0L) op hi lo = 
    let res = Sequenceops.unfold_right_i (fun (h, t) -> 
        match t > (Int64.add hi 1L) with
        | true -> None | _ -> Some (h, (op h t, Int64.add t 1L))) (init, lo)
in match res with | [] -> init | x::_ -> x
    
let sum_to_u hi lo = numseq_math_u Int64.add hi lo

let fact_u n = numseq_math_u ~init:1L Int64.mul n 1L

let fib_u n =
    let res = Sequenceops.unfold_right_i (fun (s0, s1, m) -> match m with
        | 0 -> None | _ -> Some (s1, (s1, s0 + s1, m - 1))) (0, 1, n)
in match res with | [] -> n | x::_ -> x

let pascaltri_u rows =
    let res = Sequenceops.unfold_right_i (fun (x::xs, r) -> match 0 > r with
        | true -> None | _ -> Some (x::xs, ((List.map2 (fun a b -> a + b)
        (0::x) (x @ [0])) :: (x::xs), r - 1))) ([[1]], rows)
in match res with | [] -> [] | x::_ -> List.rev x

(*
let euclid_u m n =
    let res = Sequenceops.unfold_right_i (fun (a, b) -> match b with
        | 0 -> None | _ -> Some (b, (b, a mod b))) (m, n)
in match res with | [] -> m | x::_ -> x
*)

let gcd_u xss = match xss with
    | [] -> 0
    | m::ms -> 
        let res = Sequenceops.unfold_right_i (fun (a, rst) -> match rst with
            | [] -> None
            | b::bs -> Some (_euclid a b, (_euclid a b, bs))) (m, ms)
    in match res with | [] -> m | x::_ -> x

let lcm_u xss = match xss with
    | [] -> 0
    | m::ms -> 
        let res = Sequenceops.unfold_right_i (fun (a, rst) -> match rst with
            | [] -> None
            | b::bs -> Some (a * b / _euclid a b, 
                (a * b / _euclid a b, bs))) (m, ms)
    in match res with | [] -> m | x::_ -> x

let base_expand_u b n = Sequenceops.unfold_right_i (fun x -> match x with
        | 0 -> None | _ -> Some (x mod b, x / b)) n

let base_to10_u b xss =
    let func = (fun (h, t) -> match t with
    	|	[] -> h
    	|	x::y -> (h + (x * (truncate ((float b) ** 
    		(float (List.length y))))))) in
    let res = Sequenceops.unfold_right_i (fun (h, t) -> match t with
        | [] -> None | _::xs -> Some (func (h, t), (func (h, t), xs))) (0, xss)
in match res with | [] -> b | x::_ -> x

let range_step_u ?(step = 1) ?(start = 0) stop = 
    let cmp_op = if step > 0 then (>) else (<)
in List.rev (Sequenceops.unfold_right_i (fun x -> match cmp_op x stop with
    | true -> None | _ -> Some (x, x + step)) start)

let range_u start stop = range_step_u ~start:start stop
