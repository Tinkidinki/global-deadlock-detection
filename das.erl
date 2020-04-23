-module(das).
-compile(export_all).

% For now ignores the P out of Q criterion, and codes it like an and model. 

p(X) ->
    list_to_atom(integer_to_list(X)).

send_prod(N) ->
    p(N) ! prod.

receive_node(Created_wfg, 0) -> ok;
receive_node(Created_wfg, X) ->
    receive
        {N, N_outlist} ->
            [digraph:add_vertex(Created_wfg, V) || V <- N_outlist],
            [digraph:add_edge(Created_wfg, N, V) || V <- N_outlist]
    end,
    receive_node(Created_wfg, X-1).

receive_nodes(Created_wfg, Finlist, Outlist) ->
    receive_node(Created_wfg, length(Outlist)),
    init_loop(Created_wfg, lists:append(Finlist, Outlist)).

is_deadlocked(Created_wfg, []) ->
    io:format("NOT DEADLOCKED~n", []);
is_deadlocked(Created_wfg, V_list)->
    io:format("Reaches here~n", []),
    [First | Rest] = V_list, 
    Cycle = digraph:get_cycle(Created_wfg, First),
    if 
        Cycle == false ->
            is_deadlocked(Created_wfg, Rest);
        true ->
            io:format("DEADLOCKED~n", [])
            
    end.
   

init_loop(Created_wfg, Finlist) ->
    Vertex_list = digraph:vertices(Created_wfg),
    io:format("Reaches init loop: ~w~n", [Vertex_list]),
    F = lists:sort(Finlist),
    V = lists:sort(Vertex_list),
    if 
        F == V -> ok;
        true ->
            Outlist = lists:filter(fun(X) -> not lists:member(X, Finlist) end, digraph:vertices(Created_wfg)),
            [send_prod(N) || N <- Outlist],
            receive_nodes(Created_wfg, Finlist, Outlist) 
    end.
    

init(V, Neigh, Initiator) -> %Assumption: Initiator is blocked by atleast one process.
    io:format("Reaches init~n", []),
    {Node, P} = V,
    Created_wfg = digraph:new(),
    digraph:add_vertex(Created_wfg, Node),
    [digraph:add_vertex(Created_wfg, N) || N <- Neigh],
    [digraph:add_edge(Created_wfg, Node, N) || N <- Neigh],
    io:format("Reaches before init loop~n", []),
    init_loop(Created_wfg, [Node]),
    io:format("Reaches before deadlocks~n", []),
    is_deadlocked(Created_wfg, digraph:vertices(Created_wfg)).



proc(V, Neigh, Initiator) ->
    io:format("Reaches proc~n", []),
    {Node, P} = V,
    receive
        prod ->
            p(Initiator) ! {Node, Neigh}
    end.

    

spawn_processes(Wfg, 0, Initiator) -> ok;
spawn_processes(Wfg, N, Initiator) ->
    if 
        N == Initiator ->
            register(list_to_atom(integer_to_list(N)), spawn(das, init, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]));
        true ->
            register(list_to_atom(integer_to_list(N)), spawn(das, proc, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]))
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

    