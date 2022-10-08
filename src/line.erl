-module(line).
-export([build/2]).

lineBuild(NumNodes, CurrentList, Previous, Current,_) when NumNodes == 0 ->
    NeighbourList = CurrentList ++ [{Current, [Previous]}],
    NeighbourMap = maps:from_list(NeighbourList),
    io:fwrite("~n Node map : ~w", [NeighbourList]),
    register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
    io:fwrite("~nLine Topology structuring complete");

lineBuild(NumNodes, NeighbourList, Previous, Current,Algorithm) when NumNodes > 0 ->
    if Previous =/= "" ->
        if Algorithm == "gossip"->
            Next = spawn(gossip, listenToRumor,[self(),0])
        ;true ->
            Next = spawn(pushSumActor, start,[NumNodes])
        end,
        NewList = NeighbourList ++ [{Current, [Previous, Next]}],
        lineBuild(NumNodes - 1, NewList, Current, Next,Algorithm);
    true->
        if Algorithm == "gossip"->
            Next = spawn(gossip, listenToRumor,[self(),0])
        ;true ->
            Next = spawn(pushSumActor, start,[NumNodes])
        end,
        NewList = NeighbourList ++ [{Current, [Next]}],
        lineBuild(NumNodes - 1, NewList, Current, Next,Algorithm)
    end.


build(NumNodes,Algorithm) ->
    io:fwrite("~nBuilding topology"),
    if Algorithm == "gossip"->
        Current = spawn(gossip, listenToRumor,[self(),0]),
        lineBuild(NumNodes -1,[], "", Current,Algorithm),
        Current ! "Awesome"
    ;true ->
        Current = spawn(pushSumActor, start,[NumNodes]),
        lineBuild(NumNodes -1,[], "", Current,Algorithm),
        Current ! {1,1}
    end.
