open GuestList
open Conversation

type command = 
  | Quit
  | Guests
  | Help
  | Add of string
  | PM of Conversation.message
  | Message of Conversation.message
  | Joke 
  | Quote
  | Chance of string

exception Empty

exception Malformed

let parse str send =
  let filter =  str |> String.trim 
                |> String.lowercase_ascii |> String.split_on_char ' ' 
                |> List.filter (fun s -> s <> "") in 
  match filter with 
  | [] -> raise Empty
  | [""] -> raise Empty
  | ["/help";] -> Help
  | ["/quit";] -> Quit
  | ["/joke"] -> Joke
  | ["/quote"] -> Quote
  | ["/members";] -> Guests
  | h :: t -> match h with
    | "/add" -> if List.length t = 1 then 
        Add (String.sub str 5 (String.length str - 5)) else raise Malformed
    | "/chance" -> if List.length t > 1 then 
        Chance (String.sub str 8 1) else raise Malformed
    | "/pm" -> if List.length t > 1 then 
        PM {contents = String.sub str 4 (String.length str - 4); 
            sender = send} else raise Malformed
    | _ -> Message {contents = str; sender = send}
