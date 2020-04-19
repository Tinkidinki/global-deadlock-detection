-module(t).
-compile(export_all).

send_stuff(0) -> ok;
send_stuff(N) ->
    receiver ! hi,
    send_stuff(N-1).

send() -> 
    send_stuff(1).

rec() -> ok.
    % receive 
    %     hi ->
    %         io:format("I got a hi~n", [])
    % end.



main() ->
    register(sender, spawn(t, send, [])),
    register(receiver, spawn(t, rec, [])).