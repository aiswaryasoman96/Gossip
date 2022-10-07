-module(line).
-export([build/1]).

lineBuild(NumNodes, CurrentList, Previous, Current) when NumNodes == 0 ->
    NeighbourList = CurrentList ++ [{Current, [Previous]}],
    NeighbourMap = maps:from_list(NeighbourList),
    io:fwrite("~n Node map : ~w", [NeighbourList]),
    register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
    io:fwrite("~nLine Topology structuring complete");

lineBuild(NumNodes, NeighbourList, Previous, Current) when NumNodes > 0 ->
    if Previous =/= "" ->
        Next = spawn(gossip, listenToRumor,[self(),0]),
        NewList = NeighbourList ++ [{Current, [Previous, Next]}],
        lineBuild(NumNodes - 1, NewList, Current, Next);
    true->
        Next = spawn(gossip, listenToRumor,[self(),0]),
        NewList = NeighbourList ++ [{Current, [Next]}],
        lineBuild(NumNodes - 1, NewList, Current, Next)
    end.


build(NumNodes) ->
    io:fwrite("~nSpawning in Line topology"),
    Current = spawn(gossip, listenToRumor,[self(),0]),
    lineBuild(NumNodes -1,[], "", Current),
    Current ! "Awesome".