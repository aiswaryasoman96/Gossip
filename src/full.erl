-module(full).
-export([build/2]).

makeMap(NodeList, NeighbourMapList, Index) when Index > length(NodeList) ->
    register(getNeighbours, spawn(main, getConnectedActors,[maps:from_list(NeighbourMapList)]));

makeMap(NodeList, NeighbourMapList, Index) when Index =< length(NodeList) ->
    CurrNode = lists:nth(Index, NodeList),
    NeighbourList = [T || T <- NodeList , T =/= CurrNode],
    NewNeighbourMapList = NeighbourMapList ++ [{CurrNode, NeighbourList}],
    makeMap(NodeList, NewNeighbourMapList, Index + 1).

makeNodes(_, NumNodes, NodeList) when NumNodes == 0 ->
    makeMap(NodeList, [], 1);

makeNodes(Algorithm, NumNodes, NodeList) when NumNodes > 0 ->
    NewList = NodeList ++ [spawn(Algorithm, start,[NumNodes])],
    io:fwrite("~nCreate new node ~w",[(NewList)]),
    makeNodes(Algorithm, NumNodes -1, NewList).

build(Algorithm, NumNodes) -> 
    FirstNode = spawn(Algorithm, start,[NumNodes]),
    makeNodes(Algorithm, NumNodes -1, [FirstNode]),
    if (Algorithm == 'gossip') -> 
        FirstNode ! "Awesome"
    ;true ->
        FirstNode ! {0,0}
    end.
