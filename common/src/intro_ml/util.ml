let option_get if_none opt =
    match opt with None -> if_none | Some v -> v

let daysOfWeek = [|"Sun"; "Mon"; "Tue"; "Wed"; "Thu"; "Fri"; "Sat"|]

let monthNames = [|"Jan"; "Feb"; "Mar"; "Apr"; "May"; "Jun"; "Jul"; "Aug"; "Sep"; "Oct"; "Nov"; "Dec"|]

let dateToString dt1 = Printf.sprintf "%s %s %02d %02d:%02d:%02d %04d"
    daysOfWeek.(dt1.Unix.tm_wday) monthNames.(dt1.Unix.tm_mon)
    dt1.Unix.tm_mday dt1.Unix.tm_hour dt1.Unix.tm_min dt1.Unix.tm_sec
    (dt1.Unix.tm_year + 1900)

let inicfg_tostring ini =
    let items = List.fold_left (fun acc sect ->
        let attr_vals = ini#attrs sect in
        (List.map (fun attr -> (String.concat "" [sect;":";attr],
            ini#getval sect attr)) attr_vals) :: acc) [] ini#sects in
    List.fold_right (fun el acc -> (List.fold_right (fun (a,b) acc ->
        String.concat "" ["(";a;",";b;")";", ";acc]) el "\n") ^ acc) items ""

let mkString_init (beg, sep, stop) el_fmt lst = match lst with
    |   [] -> beg ^ stop
    |   _ -> beg ^ (List.fold_right (fun el acc -> (el_fmt el) ^
        (if "" = acc then "" else sep) ^ acc) lst "") ^ stop

let mkString el_fmt lst = mkString_init ("[", "; ", "]") el_fmt lst

let mkString_nested (beg, sep, stop) el_fmt nlsts = match nlsts with
    |   [] -> beg ^ stop
    |   _ -> (List.fold_left (fun acc el -> acc ^ (mkString_init ("",sep,"\n")
        el_fmt el)) beg nlsts) ^ stop

let range_cnt ?(start=0) cnt =
    Array.to_list @@ Array.init cnt (fun e -> e + start)

let queue_ofList lst =
    let queue = Queue.create ()
in (List.iter (fun e -> Queue.add e queue) lst ; queue)

let queue_toList queue = (List.rev (Queue.fold (fun a e -> e :: a) [] queue))

let in_epsilon ?(tolerance=0.001) a b =
    let delta = abs_float tolerance in
    (* (a -. delta) <= b && (a +. delta) >= b *)
    not ((a +. delta) < b) && not ((b +. delta) < a)

let cartesian_prod xs ys =
    List.flatten @@ List.map (fun x -> List.filter (fun e -> true) @@
        List.map (fun y -> (x, y)) ys) xs

module IntOrd = struct
    type t = int
    let compare = Pervasives.compare
end

module CharOrd = struct
    type t = char
    let compare = Pervasives.compare
end

module StringOrd = struct
    type t = string
    let compare = Pervasives.compare
end

module FloatOrd = struct
    type t = float
    let compare = Pervasives.compare
end

module IntHash = struct
    type t = int
    let equal = (==)
    let hash = Hashtbl.hash
end

module CharHash = struct
    type t = char
    let equal = (==)
    let hash = Hashtbl.hash
end

module StringHash = struct
    type t = string
    let equal = (=)
    let hash = Hashtbl.hash
end

module FloatHash = struct
    type t = float
    let equal = (=)
    let hash = Hashtbl.hash
end


let lib_main argv =
    let (xs, ys) = ([0; 1; 2], [10; 20; 30]) in
    Printf.printf "cartesian_prod %s %s: %s\n" (mkString string_of_int xs)
        (mkString string_of_int ys) (mkString (fun tup -> "(" ^
        (string_of_int @@ fst tup) ^ ", " ^ (string_of_int @@ snd tup) ^ ")")
        @@ cartesian_prod xs ys)


let () =
let (program, re) = (Sys.argv.(0), Str.regexp "lib_main") in
    try let _ = Str.search_forward re program 0 in
        lib_main (Sys.argv)
    with Not_found -> ()
(*
let () =
    if !Sys.interactive then () else lib_main (Sys.argv) ;
*)
