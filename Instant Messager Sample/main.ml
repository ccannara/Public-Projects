open Lwt

(** [user_init] prompts for the the name of the user. *)
let rec user_init () = 
  print_string "Enter a username: ";
  let name = read_line () 
             |> String.split_on_char ' '
             |> List.filter (fun s -> s <> "") 
             |> String.concat "_" in

  if (Str.string_match (Str.regexp_case_fold "[a-z0-9]+$") name 0 && 
      String.length name < 21) 
  then name
  else
    begin
      ANSITerminal.(print_string [red] ("[ERROR] "));
      print_endline "Please enter a valid username comprised of \
                     sixteen or fewer letters and numbers.";
      user_init ()
    end

(** [port_init] prompts for a port number to bind the server to. *)
let rec port_init () = 
  print_string "Enter an unoccupied port number: ";
  try read_line () |> int_of_string with 
  | _ -> ANSITerminal.(print_string [red] ("[ERROR] ")); 
    print_endline "Not a valid port number"; port_init ()

(** [ip_init ()] starts system set up by prompting for an IP address 
    to host the server at. *)
let rec ip_init () = 
  print_string "\nEnter the IP address of the host server \
                (127.0.0.1 is local): ";
  try read_line () |> Unix.inet_addr_of_string with 
  | _ -> ANSITerminal.(print_string [red] ("[ERROR] ")); 
    print_endline "Not a valid IP Address"; ip_init ()

let init () =
  let ip = ip_init () in 
  let port = port_init () in
  ANSITerminal.(print_string [green] ("\n[SUCCESS] ")); 
  print_endline ("\nIP Address: " ^ Unix.string_of_inet_addr ip);
  print_endline ("Port:       " ^ string_of_int port);
  ANSITerminal.(print_string [yellow] ("\nFor you and each of your friends to\
                                        enter the chat, please type\n"));
  print_endline ("telnet " ^ Unix.string_of_inet_addr ip 
                 ^ " [Enter different port number here]");
  ANSITerminal.(print_string [yellow] ("in a different terminal \
                                        to join the chat.\n\n"));

  ANSITerminal.(print_string [green] ("Press ENTER to continue and put \
                                       server online."));
  read_line ();              
  Serv.server_init ip port

let () = init ()