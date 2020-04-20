-module(ks).
-compile(export_all).

% ks.erl with all the extra comments and code in case the need comes
receive_flood_loop()->
    receive 
        {flood, N} ->
            receive_flood_loop()
    end.

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
    % ---------------------Debugging Code--------------------------
    % io:format("Initiator, ~w~n", [Node]), 
    % io:format("Minimum resources for node ~w: ~w~n", [Node, P]), 
    % io:format("Out-neighbours for node ~w: ~w~n", [Node, Neigh]),
    % -------------------------------------------------------------
    
    % Flood everyone!
    [send_flood(N, Node) || N <- Neigh],
    receive_echo(P, true). % true means you are the initiator

proc(V, Neigh, Initiator) ->
    {Node, P} = V,

    % ---------------------Debugging Code--------------------------
    % io:format("This is V ~w~n", [V]),
    % io:format("Process, ~w~n", [Node]), 
    % io:format("Minimum resources node ~w: ~w~n", [Node, P]), 
    % io:format("Out-neighbours for node ~w: ~w~n", [Node, Neigh]).
    % -------------------------------------------------------------
     
    receive
        {flood, Engage} ->
            io:format("VALUE OF NEIGH: ~w~n", [Neigh]),
            [send_flood(N, Node) || N <- Neigh]
    end,

    receive_echo(P, false), % false means you are not the initiator
    send_echo(Engage, Node), 
    receive_flood_loop().

    


% enter_vertex(Wfg, 0) -> ok;
% enter_vertex(Wfg, N)->
%     io:format("Enter P: minimum number of resources for process ~w to run:", [N]),
%     {ok, P} = io:read("\n"),
%     digraph:add_vertex(Wfg, N, P),
%     enter_vertex(Wfg, N-1).

% enter_edge(Wfg, 0)-> ok;
% enter_edge(Wfg, N)->
%     io:format("Enter edge\n"),
%     {ok, From} = io:read("Enter From Vertex:\n"), 
%     {ok, To} = io:read("Enter To Vertex:\n"),
%     digraph:add_edge(Wfg, From, To),
%     enter_edge(Wfg, N-1).       

spawn_processes(Wfg, 0, Initiator) -> ok;
spawn_processes(Wfg, N, Initiator) ->
    if 
        N == Initiator ->
            io:format("IF PORTION ~w~n", [N]),
            register(list_to_atom(integer_to_list(N)), spawn(ks, init, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]));
        true ->
            io:format("ELSE PORTION ~w~n", [N]),
            register(list_to_atom(integer_to_list(N)), spawn(ks, proc, [digraph:vertex(Wfg, N), digraph:out_neighbours(Wfg, N), Initiator]))
    end,
    spawn_processes(Wfg, N-1, Initiator).


main([Input_file])->
    % {ok, Num_proc} = io:read("Enter number of processes:\n"),
    % {ok, Num_edges} = io:read("Enter number of edges:\n "),
    % Wfg = digraph:new(),
    % enter_vertex(Wfg, Num_proc),
    % enter_edge(Wfg, Num_edges),
    % {ok, Initiator} = io:read("Enter vertex to initiate deadlock detection:\n"),
    % spawn_processes(Wfg, Num_proc, Initiator).

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
    io:format("VERTICES ~w~n", [digraph:vertices(Wfg)]),
    io:format("TEST ~w~n", [digraph:vertex(Wfg, 3)]), 
    spawn_processes(Wfg, Num_proc, Initiator).

% More extras

% receive_flood_loop()->
%     receive 
%         {flood, N} ->
%             receive_flood_loop()
%     end.

% send_echo(Rec, Send) ->
%     list_to_atom(integer_to_list(Rec)) ! {echo, Send}.

% receive_echo(0, Initiator, Weight) -> 
%     if 
%         (Initiator) ->
%             io:format("NOT DEADLOCKED\n", []);
%         true ->
%             ok
%     end;
% receive_echo(P, Initiator, Weight) ->
%     receive
%         {echo, Node, Weight_Rec} ->
%             receive_echo(P-1, Initiator, Weight+Weight_Rec)
%     end.


    % receive_echo(P, false, 0), % false means you are not the initiator, 0 is the weight you received
    % send_echo(Engage, Node), 
    % receive_flood_loop().