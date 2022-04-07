open Conversation;;
open GuestList;;
open Conversation.GuestListQueue;;
open Command;;
open ChatBot;;
open Rsa;;

let open_connection sa =
  let domain = Unix.domain_of_sockaddr sa in
  ANSITerminal.(print_string [yellow] "§ DOMAIN FOUND\n");
  let sock = Unix.socket domain Unix.SOCK_STREAM 0 in
  ANSITerminal.(print_string [yellow] "§ SOCKET FOUND\n");
  try
    Unix.connect sock sa;
    ANSITerminal.(print_string [yellow] "§ CONNECTION FOUND\n");
    (Unix.in_channel_of_descr sock, Unix.out_channel_of_descr sock)
  with e ->
    Unix.close sock;
    ANSITerminal.(print_string [red] "§ Failure. No server.\n");
    raise e

let close_connection ic =
  Unix.shutdown (Unix.descr_of_in_channel ic) Unix.SHUTDOWN_SEND

let get_response m ic oc =
  try
    output_string oc (m ^ "\n");
    flush oc;
    let r = input_line ic in
    Some r
  with e -> None

(* ====================================== *)

let send_request m p =
  (* Open up the connection to the server *)
  let address = Unix.((gethostname () |> gethostbyname).h_addr_list.(0)) in
  ANSITerminal.(print_string [yellow] "§ ADDRESS FOUND\n");
  try
    let (ic, oc) = open_connection (Unix.ADDR_INET (address, p)) in
    ANSITerminal.(print_string [green] "§ CONNECTED\n");

    (* Send the request and process the response *)
    let resp = Unix.handle_unix_error (get_response m ic) oc in

    (* Close the connection *)
    close_connection ic;

    (* Return the response *)
    resp
  with e -> None

(* SERVER STUFF ========================== *)
let rec run_client (u : user) (g : GuestListQueue.t) 
    (c : Conversation.t) =
  print_string  "» ";

  let rec validate_message msg =
    try
      match msg with
      | Quit -> exit 0;
      | Guests -> 
        ANSITerminal.(print_string [yellow] "Total members: "); 
        print_endline (string_of_int(size g) ^ "/99"); 
        List.iter (fun (i, u) -> print_endline (i ^ " " ^ u)) (to_list g);
        print_endline "";
        run_client u g c;
      | Help -> 
        ANSITerminal.
          ((print_string [yellow] "\nCommands:\n"); 
           (print_string [cyan] 
              ("/quit\t\t\t\tEnds the client and quits Tatami\n" ^
               "/members\t\t\tShows all the members of the current room\n" ^
               "/add [name]\t\t\tAdds a client with [name] to current room\n" ^
               "/add [#id] [message]\t\tSends private message to [#id]\n\n")));
        run_client u g c;
      | Add n -> print_endline (n ^ " has been added to the chat");
        let rid = generate_id g in
        run_client u (GuestListQueue.insert rid n g) c;
      | PM m -> let to_user = String.sub m.contents 0 7 in 
        if (member to_user g) && (Str.compare u.id to_user != EQ) then
          let m =(String.sub m.contents 8 (String.length m.contents - 8)) in 
          ANSITerminal.(print_string [magenta] 
                          ("Private message sent to " ^ to_user ^ ": "));
          print_endline m;
        else 
          print_endline ((String.sub m.contents 0 7) ^ " is not a user.");
        run_client u g c;
      | Joke -> print_endline ("Here's your joke!!!!!:"); 
        ANSITerminal.(print_string [yellow] 
                        (ChatBot.jokes()));  run_client u g c;
      | Quote -> print_endline ("Here's your quote mate!!!!!:"); 
        ANSITerminal.(print_string [yellow] 
                        (ChatBot.quote() ));  run_client u g c;
      | Chance m -> print_string ("The chance of that is: " ); 
        ANSITerminal.(print_int 
                        (ChatBot.chance_of m )); print_endline (""); 
        run_client u g c;
      | Message m -> 
        (* print_endline "
           For the sake of MS2, please enter a port number to 
           successfully send the message. The port number MUST be an integer. 
           We usually set the port to 80, assuming we set up an Apache server on 
           XAMPP. If the port number does not exist, the message will not be sent 
           and will give you a failure message. Otherwise, it should work.
           In addition, if the server is up, please give it time to connect.
           The program doesn't connect to the internet immediately because we want
           you, the grader, to be able to put your own port number, since we have
           not set up our own server yet. So you should try multiple times if it
           failed the first time.\n"; *)
        print_string  "» ";
        let n = int_of_string (read_line ()) in
        match send_request m.contents n with
        | Some resp -> print_endline "Message sent!\n";
          let c' = Conversation.insert m c in Conversation.print_conv c';
          run_client u g c';
        | None -> print_endline "Request unsuccessful"; 
          Conversation.print_conv c; run_client u g c;


    with
    | _ -> print_endline "Bad command. Try again";  
      ANSITerminal.
        ((print_string [yellow] "\nCommands:\n"); 
         (print_string [cyan] 
            ("/quit\t\t\t\tEnds the client and quits Tatami\n" ^
             "/members\t\t\tShows all the members of the current room\n" ^
             "/add [name]\t\t\tAdds a client with [name] to current room\n" ^
             "/add [#id] [message]\t\tSends private message to [#id]\n\n")));
      run_client u g c
  in try 
    let m = parse (read_line ()) u in validate_message m
  with 
  | Command.Empty -> run_client u g c
  | Command.Malformed -> print_endline "Bad command. Try again.";  
    ANSITerminal.
      ((print_string [yellow] "\nCommands:\n"); 
       (print_string [cyan] 
          ("/quit\t\t\t\tEnds the client and quits Tatami\n" ^
           "/members\t\t\tShows all the members of the current room\n" ^
           "/add [name]\t\t\tAdds a client with [name] to current room\n" ^
           "/add [#id] [message]\t\tSends private message to [#id]\n\n"))); 
    run_client u g c
  | End_of_file -> exit 0


let cli () =
  ANSITerminal.(print_string [yellow]
                  "\n\nTatami Chat (Alpha).\n");
  print_endline "Welcome to Local Chat. Please enter a name.";
  print_string  "» ";

  let rec validate_name = function
    | name -> if String.length name > 0 then 
        begin
          print_string ("\n\nWelcome to Tatami, ");
          let id = generate_id (GuestListQueue.empty) in 
          let cid = generate_color id in
          ANSITerminal.(print_string [cid] (id ^ " " ^ name ^ "\n")); 
          run_client {id = id; name = name; color = cid;} 
            (GuestListQueue.insert id name GuestListQueue.empty) 
            Conversation.empty; 
        end 
      else 
        print_endline "\nPlease enter a valid name (not empty).";
      print_string  "» ";
      let name =(read_line () |> String.split_on_char ' '
                 |> List.filter (fun s -> s <> "") |> String.concat "_") in
      validate_name (name) in

  let name =(read_line () |> String.split_on_char ' '
             |> List.filter (fun s -> s <> "") |> String.concat "_") in
  validate_name (name)

(* Execute the client. *)
let () = cli ()