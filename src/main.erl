-module(main).
-export([start/3, getConnectedActors/1]).
-import_module(server).

% Generic method to keep the track of neighbours of any node. Idea is to store the info in a map(PID, Neighbourlist) format
getConnectedActors(NeighbourMap) ->
    receive
        MyPID ->
            % io:fwrite("~n Map ~w", [maps:to_list(NeighbourMap)]),
            % io:fwrite("~n Caller PID ~w", [MyPID]),
            % io:fwrite("~n Neighbours ~w", [maps:get(MyPID, NeighbourMap)]),
            MyPID ! maps:get(MyPID, NeighbourMap)
    end,
    getConnectedActors(NeighbourMap).
            

start(NumNodes, Topology, Algorithm)->
    case Algorithm of 
        gossip -> 
            io:fwrite("Starting the Gossip...."),
            case Topology of 
                line ->
                    line:build(NumNodes);
                full ->
                    full:build(NumNodes);
                '2D' ->
                    twoDGrid:build(NumNodes)
            end;        

        push_sum ->
            case Topology of 
                line ->
                    line:build(NumNodes,"push-Sum");
                full ->
                    full:build(NumNodes);
                '2D' ->
                    twoDGrid:build(NumNodes,"push-Sum")
            end
    end.
    
