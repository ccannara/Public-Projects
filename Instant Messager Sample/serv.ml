open Lwt
open Rsa

let backlog = 100

let conversation = ref ""
let k_inv = ref 0
let m = ref 0
let count = ref 0

let handle_message msg =
  try
    if (String.sub msg 0 8 = "/decrypt") then 
      let x = String.sub msg 9 (String.length msg - 9) in 
      let y =(final_dec x !k_inv !m) in 
      count := !count + 1; 
      conversation := !conversation ^ "\nMessage #" ^ 
                      string_of_int !count ^ ": " ^ y; ""
    else if (String.sub msg 0 8 = "/encrypt") then 
      let x = String.sub msg 9 (String.length msg - 9) |> String.trim |> String.lowercase_ascii 
              |> String.split_on_char ' ' in
      let k = List.hd x |> int_of_string in 
      let m = List.nth x 1 |> int_of_string in
      let y =(encrypt (String.sub msg 13 (String.length msg -13)) k m |> final_enc) in 
      count := !count + 1; 
      conversation := !conversation ^ "\nMessage #" ^ 
                      string_of_int !count ^ ": " ^ y; ""

    else failwith "unbound";
  with 
  | _ ->
    match msg with
    | "/help" -> "There is only one command:/refresh"^
                 "Typing either one of these commands will show all messages.\n" ^
                 "Ig you would like to quit, please press Ctrl +C.\n" 

    |"/refresh" -> !conversation
    |"/rsa" -> count := !count + 1; 
      let msgkm = match receiver () with
        |(a,b,c,d)-> k_inv:=d; m:=a;(a |> string_of_int) ^" " ^(c |> string_of_int) in
      conversation := !conversation ^ "\nMessage #" ^ 
                      string_of_int !count ^ ": " ^ msgkm; ""
    | _  -> count := !count + 1; 
      conversation := !conversation ^ "\nMessage #" ^ 
                      string_of_int !count ^ ": " ^ msg; ""


let rec handle_connection ic oc () =
  Lwt_io.write_line oc "\nWrite message below. Type /help for more commands";
  Lwt_io.read_line_opt ic >>=
  (fun msg ->
     match msg with
     | Some msg -> 
       let reply = handle_message msg in
       Lwt_io.write_line oc reply >>= handle_connection ic oc
     | None -> Logs_lwt.info (fun m -> m "Connection closed") >>= return)

let accept_connection conn =
  let fd, _ = conn in
  let ic = Lwt_io.of_fd Lwt_io.Input fd in
  let oc = Lwt_io.of_fd Lwt_io.Output fd in
  Lwt.on_failure (handle_connection ic oc ()) 
    (fun e -> Logs.err (fun m -> m "%s" (Printexc.to_string e) ));
  Logs_lwt.info (fun m -> m "New connection") >>= return

let create_server sock =
  let rec serve () =
    Lwt_unix.accept sock >>= accept_connection >>= serve
  in serve

let create_socket ip p =
  let open Lwt_unix in
  let sock = socket PF_INET SOCK_STREAM 0 in
  bind sock @@ ADDR_INET(ip, p);
  listen sock backlog;
  sock

let server_init ip p =
  let sock = create_socket ip p in
  let serve = create_server sock in
  Lwt_main.run @@ serve ()