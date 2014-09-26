let squares_strm () =
    (*let rec iter z = Stream.icons (z *. z) (iter (z +. 1.0))
in Stream.icons 0.0 (iter 1.0)*)
	let rec iter z = [<'(z *. z); iter (z +. 1.0)>]
in [<'0.0; iter 1.0>]

let expts_strm b =
    let rec iter z = [<'(z *. b); iter (z *. b)>]
in [<'1.0; iter 1.0>]


let sums_strm lo =
    let rec iter z ct = [<'(Int64.add z ct); 
		iter (Int64.add z ct) (Int64.add ct 1L)>]
in [<'lo; iter lo (Int64.add lo 1L)>]

let facts_strm () =
    let rec iter z ct =
        [<'(Int64.mul z ct); iter (Int64.mul z ct) (Int64.add ct 1L)>]
in [<'1L; iter 1L 1L>]


let fibs_strm () =
    let rec iter s0 s1 = [<'(s0 + s1); iter s1 (s0 + s1)>]
in [<'0; '1; iter 0 1>]

let pascalrows_strm () =
    let rec iter row =
        [<'row; iter (List.map2 (fun a b -> a + b) (0::row) (row @ [0]))>]
in iter [1]


(*let squares_u () =
    let floats = BatLazyList.seq 0.0 (fun e -> e +. 1.0) (fun _ -> true)
in BatLazyList.map2 (fun e _ -> e *. e) floats floats*)
(*let squares_u () = 
    let floats = BatLazyList.from_loop 0.0 (fun e -> (e, 1.0 +. e))
in BatLazyList.map2 (fun e _ -> e *. e) floats floats*)
let squares_u () = BatLazyList.unfold 0.0 (fun z -> Some (z *. z, z +. 1.0))

let expts_u b = BatLazyList.unfold 1.0 (fun z -> Some (z, z *. b))

let sums_u lo = BatLazyList.unfold (lo, 1L) (fun (z, ct) -> 
	Some (z, (Int64.add z @@ Int64.add ct lo, Int64.add ct 1L)))

let facts_u () = BatLazyList.unfold (1L, 1L) (fun (z, ct) -> 
	Some (z, (Int64.mul z ct, Int64.add ct 1L)))

let fibs_u () = BatLazyList.unfold (0, 1) (fun (s0, s1) -> 
	Some (s0, (s1, s0 + s1)))

let pascalrows_u () = BatLazyList.unfold [1] (fun row -> 
	Some (row, List.map2 (fun a b -> a + b) (0::row) (row @ [0])))
