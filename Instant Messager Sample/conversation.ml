open GuestList;;

module Str = struct
  type t = string
  let compare x y =
    match Stdlib.compare x y with
    | x when x<0 -> GuestList.LT
    | 0 -> EQ
    | _ -> GT
  let format fmt (x:t) =
    Format.fprintf fmt "%s" x
end;;


module Stri = struct
  type t = string
  let appender x y = x^y
  let compare x y =
    match Stdlib.compare x y with
    | x when x<0 -> GuestList.LT
    | 0 -> EQ
    | _ -> GT
  let format fmt (x:t) =
    Format.fprintf fmt "%s" x
end;;


(* The next line creates a dictionary that maps ints to ints. *)
module GuestListQueue = GuestListDictionary.Make(Str)(Stri);;

open GuestListQueue;;

type user = {
  id : Identity.t;
  name : User.t;
  color: ANSITerminal.style;
}

type message =
  {
    contents: string;
    sender: user;
  }

type t = message list

let empty = []

let insert (m:message) (c:t) = c@[m]

let generate_color id =
  Random.self_init ();
  match int_of_string (String.sub id 1 6) mod 6 with
  | 0 -> ANSITerminal.(Foreground Red) 
  | 1 -> ANSITerminal.(Foreground Yellow) 
  | 2 -> ANSITerminal.(Foreground Green) 
  | 3 -> ANSITerminal.(Foreground Blue)  
  | 4 -> ANSITerminal.(Foreground Magenta) 
  | _ -> ANSITerminal.(Foreground Cyan)

let rec generate_id (g: GuestListQueue.t) =
  Random.self_init ();
  let rid = string_of_int (Random.int 1000000) in 
  if member rid g then generate_id g else
    "#" ^ (String.make (6 - String.length rid) '0') ^ rid

let rec print_conv (c:t) =
  match c with
  | [] -> print_endline "";
  | h :: t -> 
    ANSITerminal.(print_string [h.sender.color] 
                    (h.sender.id ^ " " ^ h.sender.name));
    print_endline (": " ^ h.contents); print_conv t