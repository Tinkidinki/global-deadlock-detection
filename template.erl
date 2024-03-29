-module(template).
-compile(export_all).

% Note: to send a message to any node, first convert it to an atom as: list_to_atom(integer_to_list(Node)).

init(V, Neigh, Initiator) ->
    {Node, P} = V,
    io:format("Initiator, ~w~n", [Node]), 
    io:format("Minimum resources for node ~w: ~w~n", [Node, P]), 
    io:format("Out-neighbours for node ~w: ~w~n", [Node, Neigh]).
    % Write code for what initiator needs to do here (change the preceding comma to a fullstop)

proc(V, Neigh, Initiator) ->
    {Node, P} = V,
    io:format("Process, ~w~n", [Node]), 
    io:format("Minimum resources node ~w: ~w~n", [Node, P]), 
    io:format("Out-neighbours for node ~w: ~w~n", [Node, Neigh]).
    % Write code for what other processes need to do here (change the preceding comma to a fullstop)
   


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
            register(list_to_atom(integer_to_list(N)), spawn(template, init, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]));
        true ->
            register(list_to_atom(integer_to_list(N)), spawn(template, proc, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]))
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