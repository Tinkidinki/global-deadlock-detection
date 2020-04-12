-module(kshemkalyani_singhal).
-compile(export_all).

send_flood(Rec, Send) ->
    list_to_atom(integer_to_list(Rec)) ! {flood, Send}.

send_echo(Rec, Send) ->
    list_to_atom(integer_to_list(Rec)) ! {echo, Send}.

receive_echo(0, Initiator) -> 
    if 
        (Initiator) ->
            io:format("NOT DEADLOCKED\n", []);
        true ->
            ok
    end;
receive_echo(P, Initiator) ->
    receive
        {echo, Node} -> ok
    end,
    receive_echo(P-1, Initiator).

init(V, Neigh, Initiator) ->
    {Node, P} = V,
    io:format("Initiator, ~w~n", [Node]), 
    io:format("Minimum resources for node ~w: ~w~n", [Node, P]), 
    io:format("Out-neighbours for node ~w: ~w~n", [Node, Neigh]),
    % Write code for what initiator needs to do here.

    % Flood everyone!
    % lists:foreach(send_flood, Neigh),
    [send_flood(N, Node) || N <- Neigh],
    receive_echo(P, true). % true means you are the initiator

proc(V, Neigh, Initiator) ->
    {Node, P} = V,
    io:format("Process, ~w~n", [Node]), 
    io:format("Minimum resources node ~w: ~w~n", [Node, P]), 
    io:format("Out-neighbours for node ~w: ~w~n", [Node, Neigh]),
    
    % Write code for what other processes need to do here. 
    receive
        {flood, Engage} ->
            [send_flood(N, Node) || N <- Neigh]
    end,

    receive_echo(P, false), % false means you are not the initiator
    send_echo(Engage, Node).

    


enter_vertex(Wfg, 0) -> ok;
enter_vertex(Wfg, N)->
    io:format("Enter P: minimum number of resources for process ~w to run:", [N]),
    {ok, P} = io:read("\n"),
    digraph:add_vertex(Wfg, N, P),
    enter_vertex(Wfg, N-1).

enter_edge(Wfg, 0)-> ok;
enter_edge(Wfg, N)->
    io:format("Enter edge\n"),
    {ok, From} = io:read("Enter From Vertex:\n"), 
    {ok, To} = io:read("Enter To Vertex:\n"),
    digraph:add_edge(Wfg, From, To),
    enter_edge(Wfg, N-1).

spawn_processes(Wfg, 0, Initiator) -> ok;
spawn_processes(Wfg, N, Initiator) ->
    if 
        N == Initiator ->
            register(list_to_atom(integer_to_list(N)), spawn(kshemkalyani_singhal, init, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]));
        true ->
            register(list_to_atom(integer_to_list(N)), spawn(kshemkalyani_singhal, proc, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]))
    end,
    spawn_processes(Wfg, N-1, Initiator).


main()->
    {ok, Num_proc} = io:read("Enter number of processes:\n"),
    {ok, Num_edges} = io:read("Enter number of edges:\n "),
    Wfg = digraph:new(),
    enter_vertex(Wfg, Num_proc),
    enter_edge(Wfg, Num_edges),
    {ok, Initiator} = io:read("Enter vertex to initiate deadlock detection:\n"),
    spawn_processes(Wfg, Num_proc, Initiator).