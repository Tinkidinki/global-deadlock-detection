-module(ks).
-compile(export_all).

p(X) ->
    list_to_atom(integer_to_list(X)).

send_flood(Rec, Sender, Weight) ->
    p(Rec) ! {flood, Sender, Weight}.

init_receive_loop(Weight_curr,0) ->  %received  back all its echoes
    io:format("NOT DEADLOCKED~n", []);
init_receive_loop(1.0, P) -> %algorithm terminated, but yet to receive echoes
    io:format("DEADLOCKED~n", []);
init_receive_loop(Weight_curr, P) ->
    io:format("Enters init_receive_loop: ~w, ~w ~n",[Weight_curr, P]),
    receive
        {flood, Sender, Weight_new} ->
            init_receive_loop(Weight_curr + Weight_new, P);
        {echo, Weight_new} ->
            init_receive_loop(Weight_curr + Weight_new, P-1);
        {short, Weight_new} ->
            init_receive_loop(Weight_curr + Weight_new, P)
    end.


init(V, Neigh, Initiator) -> %Assumption: Initiator is blocked by atleast one process. 
    {Node, P} = V,
    Num_neigh = length(Neigh),
    Weight = 1/Num_neigh,
    io:format("Weight distributed: ~w~n", [Weight]),
    [send_flood(N, Node, Weight) || N <- Neigh],
    init_receive_loop(0, P).
    
send_echo(Node, Weight) ->
    io:format("Node is: ~w~n", [Node]),
    p(Node) ! {echo, Weight}.

proc_receive_loop_red(Initiator) ->
    receive
        {flood, Sender, Weight} ->
            p(Sender) ! {echo, Weight};
        {echo, Weight} ->
            p(Initiator) ! {short, Weight}
    end, 
    proc_receive_loop_red(Initiator).

proc_receive_loop(Flood_list, Initiator, Weight_curr, 0) ->
    io:format("Flood list: ~w~n", [Flood_list]),
    Weight_send = Weight_curr/length(Flood_list),
    [send_echo(N, Weight_send) || N <- Flood_list],
    proc_receive_loop_red(Initiator);

proc_receive_loop(Flood_list, Initiator, Weight_curr, P) ->
    p(Initiator) ! {short, Weight_curr},
    receive
        {flood, Sender, Weight_new} ->
            proc_receive_loop(lists:append(Flood_list, Sender), Initiator, Weight_new, P);
        {echo, Weight_new} ->
            proc_receive_loop(Flood_list, Initiator, Weight_new, P-1)
    end.

proc(V, Neigh, Initiator) ->
    {Node, P} = V,

    receive
        {flood, Engager, Weight} ->
            Num_neigh = length(Neigh),
            if
                Num_neigh == 0 ->
                    Weight_send = 0;
                true ->
                    Weight_send = Weight/Num_neigh
            end,
            Weight_left = Weight - Weight_send,
            [send_flood(N, Node, Weight_send) || N <- Neigh]
    end,

    proc_receive_loop([Engager], Initiator, Weight_left, P).

    

spawn_processes(Wfg, 0, Initiator) -> ok;
spawn_processes(Wfg, N, Initiator) ->
    if 
        N == Initiator ->
            register(list_to_atom(integer_to_list(N)), spawn(ks, init, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]));
        true ->
            register(list_to_atom(integer_to_list(N)), spawn(ks, proc, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]))
    end,
    spawn_processes(Wfg, N-1, Initiator).


main(Input_file)->

    Wfg = digraph:new(),
    Input_file_string = atom_to_list(Input_file),
    {ok, Data} = file:read_file(Input_file_string), 
    Input_list = [binary_to_integer(X) || X <- string:lexemes(Data, " \t\n")],
    io:format("List: ~w~n", [Input_list]),
    
    Num_proc = lists:nth(1, Input_list),
    Num_edges = lists:nth(2, Input_list),
    P_values = lists:sublist(Input_list, 3, Num_proc),
    From_values = lists:sublist(Input_list, 3+Num_proc, Num_edges),
    To_values = lists:sublist(Input_list, 3+Num_proc+Num_edges, Num_edges),
    Initiator = lists:last(Input_list),

    [digraph:add_vertex(Wfg, I, lists:nth(I, P_values)) || I <- lists:seq(1, Num_proc)],
    [digraph:add_edge(Wfg, lists:nth(I, From_values), lists:nth(I, To_values)) || I <- lists:seq(1, Num_edges)],
    spawn_processes(Wfg, Num_proc, Initiator).

    