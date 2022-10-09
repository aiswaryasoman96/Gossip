-module(line).
-export([build/2]).

lineBuild(_, NumNodes, CurrentList, Previous, Current) when NumNodes == 0 ->
    NeighbourList = CurrentList ++ [{Current, [Previous]}],
    NeighbourMap = maps:from_list(NeighbourList),
    io:fwrite("~n Node map : ~w", [NeighbourList]),
    register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
    io:fwrite("~nLine Topology structuring complete");

lineBuild(Algorithm, NumNodes, NeighbourList, Previous, Current) when NumNodes > 0 ->
    if Previous =/= "" ->
        Next = spawn(Algorithm, start,[NumNodes]),
        NewList = NeighbourList ++ [{Current, [Previous, Next]}],
        lineBuild(Algorithm, NumNodes - 1, NewList, Current, Next);
    true->
        Next = spawn(Algorithm, start,[NumNodes]),
        NewList = NeighbourList ++ [{Current, [Next]}],
        lineBuild(Algorithm, NumNodes - 1, NewList, Current, Next)
    end.


build(Algorithm, NumNodes) ->
    io:fwrite("~nBuilding in Line topology"),
    Current = spawn(Algorithm, start,[NumNodes]),
    lineBuild(Algorithm, NumNodes -1,[], "", Current),
    if (Algorithm == 'gossip') -> 
        Current ! "Awesome"
    ;true ->
        Current ! {1, 1}
    end.