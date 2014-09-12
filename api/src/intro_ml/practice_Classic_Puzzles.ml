module IntMap = Map.Make(Util.IntOrd)

let rec hanoi (src, dest, spare) num_disks = match num_disks <= 0 with
    |   true -> []
    |   _ -> (hanoi (src, spare, dest) (num_disks - 1)) @ [(src, dest)] @
            (hanoi (spare, dest, src) (num_disks - 1))

let hanoi_moves (src, dest, spare) num_disks = 
(*
    let hanoi_pegs res =            (* mutable version using Array.set *)
        let rec iter vec_pegs lst acc = match lst with
            |   [] -> acc
            |   x::xs ->
                let (el1, el2) = ((fst x) - 1, (snd x) - 1) in
                let lst2 = (Array.get vec_pegs el2) in
                let peg_dnarr = match (Array.get vec_pegs el1) with
                    |   [] -> []
                    |   d1::rst1 ->
                        Array.set vec_pegs el1 rst1
                in Array.set vec_pegs el2 (d1 :: lst2)
        in iter vec_pegs xs ((Array.to_list vec_pegs) :: acc) 
    in List.rev (iter [|(Util.range (num_disks + 1) ~start:1); []; []|] res []) in
*)(*
    let hanoi_pegs res =            (* immutable version using alists *)
        let rec iter lst_pegs lst acc = match lst with
            |   [] -> acc
            |   x::xs -> 
                let (el1, el2) = ((fst x) - 1, (snd x) - 1) in
                let lst2 = (List.assoc el2 peg_uplst) in
                let peg_dnlst = match (List.assoc el1 lst_pegs) with
                    |   [] -> []
                    |   d1::rst1 -> 
                        let peg_uplst = (el1, rst1)) ::
                        (List.remove_assoc el1 lst_pegs)
                in (el2, d1::lst2)) :: peg_uplst
        in iter peg_dnlst xs ([(List.assoc 0 peg_dnlst); (List.assoc 1 
            peg_dnlst); (List.assoc 2 peg_dnlst)] :: acc)
    in List.rev (iter [(0, (Util.range (num_disks + 1) ~start:1)); (1, []); 
        (2, [])] res []) in 
*)
    let hanoi_pegs res =            (* immutable version using dict/maps *)
        let map1 = List.fold_left (fun acc (idx, lst) -> 
            IntMap.add idx lst acc) IntMap.empty
            [(0, Array.to_list (Array.init num_disks (fun x -> x + 1)));
            (1, []); (2, [])] in 
        let rec iter map_pegs lst acc = match lst with
            |   [] -> acc
            |   x::xs -> 
                let (el1, el2) = ((fst x) - 1, (snd x) - 1) in
                let lst2 = (IntMap.find el2 map_pegs) in
                let peg_dnmap = match (IntMap.find el1 map_pegs) with
                    |   [] -> IntMap.empty
                    |   d1::rst1 -> 
                        let peg_upmap = IntMap.add el1 rst1 map_pegs
                in IntMap.add el2 (d1::lst2) peg_upmap
        in iter peg_dnmap xs ((List.fold_left (fun a i -> 
            (IntMap.find i peg_dnmap) :: a) [] [2;1;0]) :: acc)
    in List.rev (iter map1 res []) in 

    let stat_txt res_len =
        let calc_len = (truncate (2.0 ** (float num_disks))) - 1
        in
        Printf.sprintf "((n = %d) 2^n - 1 = %d %s (length(result) = %d\n"
            num_disks calc_len 
            (if calc_len = res_len then "==" else "<>") res_len in
    let txt_fmt = format_of_string "'move from %d to %d'" in
    let res = hanoi (src, dest, spare) num_disks in
    let proc = (fun (h, t) -> Printf.sprintf txt_fmt h t)
in (res, [stat_txt (List.length res); String.make 40 '-'],
        List.combine (List.map proc res) (hanoi_pegs res))

let nqueens n =
    let threatp (x1,y1) (x2,y2) =
        (x1 = x2) || (y1 = y2) || ((abs (x1 - x2)) = (abs (y1 - y2))) in
    let rec safep (col, row) placed_set = match placed_set with
        |   [] -> true
        |   x::xs -> if threatp (col, row) x then false
                    else safep (col, row) xs in
    let rec iter col row placed_set board = 
        if (n - 1) < col then (List.rev placed_set :: board)
        else if (n - 1) < row then board
        else if safep (col, row) placed_set then
            iter col (row + 1) placed_set (iter (col + 1) 0 ((col, row) :: 
                placed_set) board)
        else iter col (row + 1) placed_set board
in iter 0 0 [] []
(*
let nqueens_grid num_queens answer =    (* mutable version using Array.set *)
    let lst_n = Array.to_list (Array.init num_queens (fun x -> x)) in
    let calc_grid el = abs ((el + 1) - num_queens) in
    let arr2d = Array.make_matrix (num_queens + 1) (num_queens + 1) " " in
    (List.iter (fun el -> Array.set arr2d.((calc_grid el)) 0 
        (string_of_int el)) lst_n ;
    List.iter (fun el -> Array.set arr2d.(num_queens) (el + 1) 
        (Char.escaped (Char.chr (el + (Char.code 'a')))) ) lst_n ;
    List.iter (fun (h, t) -> Array.set arr2d.(calc_grid t) (h + 1) "Q") answer ;
    Array.to_list (Array.map (fun a -> Array.to_list a) arr2d)
    )
*)
let nqueens_grid num_queens answer =    (* immutable version *)
    let lst_n = Array.to_list (Array.init num_queens (fun x -> x)) in
    let mk_row acc (h, t) =
        let lst_blank = List.map (fun _ -> " ") lst_n in 
        ((string_of_int t) :: (List.mapi (fun i e -> if i = h then "Q"
            else e) lst_blank)) :: acc in
    let lst_ltrs = " " :: (List.map (fun x -> Char.escaped (Char.chr (x + 
        (Char.code 'a')))) lst_n)
in List.fold_left mk_row [lst_ltrs] (List.sort 
        (fun (_, at) (_, bt) -> compare at bt) answer)

