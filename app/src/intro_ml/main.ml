(* multi-line comment
    -- run w/out compile --
    BOLT_CONFIG=bolt.conf [sh | [ocaml | utop] -I `ocamlfind query bolt`] main.sh arg1 argN

    -- run REPL, load script, & run --
    BOLT_CONFIG=bolt.conf [ocaml | utop] -I `ocamlfind query bolt` -init main.sh
    # Main.main ([|Sys.argv.(2); arg1; argN|])
    
    -- help/info tools in REPL --
    #list, #quit, #show, #trace, #untrace[_all]
    
    -- show module version 4.01  (version 4.02 and above)
    module Malias = List ;;       (#show List ;;)      -- for modules
    module Falias = Set.Make ;;   (#show Set.Make ;;)  -- for functors
*)

open Printf

module Opts_record = struct
    type t = { user:string }
end

let run_intro user =
    let rexp = Str.regexp_case_fold "^quit$" in
    begin
        printf "%s %s to %s\n" 
            (if (Str.string_match rexp user 0) then
                "Good match: "
            else "Does not match: ") user "\"^quit$\""
    end

let usage_msg = sprintf "Usage: %s [-help][-u USER]" 
    Sys.argv.(0)
let user = ref "World"

let speclist = [
    ("-u", Arg.Set_string user, ": User name")
    ]

let parse_cmdopts args =
    Bolt.Logger.log "root" Bolt.Level.INFO "parse_cmdopts()"
    ; try
    begin
        Arg.parse_argv args speclist (fun x -> raise (Arg.Bad ("Bad argument: " 
            ^ x))) usage_msg
        ; {Opts_record.user = !user}
    end
    with Arg.Help msg -> (printf "%s" msg ; exit 1)
        | Arg.Bad msg -> (printf "%s" msg ; exit 1)

let main argv = 
    let rsrc_path = try Sys.getenv "RSRC_PATH"
    with exc -> "resources" in
    let (ini_path, json_path) = (rsrc_path ^ "/prac.conf",
        rsrc_path ^ "/prac.json") in
    let opts_rec = parse_cmdopts argv in
    let ini_cfg = new Inifiles.inifile ini_path in
    let jsonobj = Yojson.Safe.from_file json_path in
    let user1Lst = Yojson.Safe.Util.member "user1" jsonobj in
    let jsonobj1 = Ezjsonm.from_channel (open_in json_path) in
    let user1Lst1 = Ezjsonm.find jsonobj1 ["user1"] in
    let tup_lst = [(Intro.inicfg_tostring ini_cfg
        , ini_cfg#getval "default" "domain"
        , ini_cfg#getval "user1" "name")
        ; (Yojson.Safe.pretty_to_string jsonobj
        , Yojson.Safe.to_string @@ Yojson.Safe.Util.member "domain" jsonobj
        , Yojson.Safe.to_string @@ Yojson.Safe.Util.member "name" user1Lst)
        ; (Ezjsonm.to_string jsonobj1
        , Ezjsonm.get_string @@ Ezjsonm.find jsonobj1 ["domain"]
        , Ezjsonm.get_string @@ Ezjsonm.find user1Lst1 ["name"])] in
    List.iter (fun (t0, t1, t2) -> 
        printf "config: {\%s}\n" t0
        ; printf "domain: %s\n" t1
        ; printf "user1Name: %s\n\n" t2 ; ()) tup_lst
    ; run_intro (opts_rec.Opts_record.user)

(*
let () =
let (program, re) = (Sys.argv.(0), Str.regexp "main") in
    try let _ = Str.search_forward re program 0 in
        main (Sys.argv)
    with Not_found -> ()
*)
let () = 
    if !Sys.interactive then () else main (Sys.argv) ;
