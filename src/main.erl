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
    io:fwrite("Starting ~n"),
    % Fill this part up based on the topology

    case Algorithm of 
        gossip ->
            % temporary testing
            Pid1 = spawn(gossip, listenToRumor,[self(),0]),
            Pid2 = spawn(gossip, listenToRumor,[self(),0]),
            Pid3 = spawn(gossip, listenToRumor,[self(),0]),
            NeighbourMap = maps:from_list([{Pid1, [Pid2, Pid3]},{Pid2, [Pid1, Pid3]},{Pid3, [Pid1, Pid2]}]),
            register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
            Pid1 ! "Awesome";
        
        pushSumActor ->
            Pid1 = spawn(pushSumActor, start),
            Pid2 = spawn(pushSumActor, start),
            Pid3 = spawn(pushSumActor, start),
            {Pid1} ! [Pid2,Pid3],
            {Pid2} ! [Pid1,Pid3],
            {Pid3} ! [Pid1,Pid2]
    end.
    
