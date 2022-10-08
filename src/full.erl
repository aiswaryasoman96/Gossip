-module(full).
-export([build/2, getNeighbourList/1]).

getNeighbourList(NodeList) ->
    receive
        MyPID ->
            Nth = rand:uniform(length(NodeList)),
            ChosenNeighbour = lists:nth(Nth, NodeList),
            if ChosenNeighbour =/= MyPID ->
                MyPID ! [ChosenNeighbour]
            ; true ->
                getNeighbours ! MyPID
            end
    end,
    getNeighbourList(NodeList).


makeNodes(NumNodes, NodeList,_) when NumNodes ==0 ->
    register(getNeighbours, spawn(full, getNeighbourList,[NodeList]));

makeNodes(NumNodes, NodeList,Algorithm) when NumNodes > 0 ->
    if Algorithm == "gossip" ->
        NewList = NodeList ++ [spawn(gossip, listenToRumor,[self(),0])]
    ;true->
        NewList = NodeList ++ [spawn(pushSumActor, start,[NumNodes])]
    end,
    makeNodes(NumNodes -1, NewList,Algorithm).

build(NumNodes,Algorithm) -> 
    if Algorithm == "gossip" ->
        FirstNode = spawn(gossip, listenToRumor,[self(),0]),
        makeNodes(NumNodes -1, [FirstNode],Algorithm),
        FirstNode ! "Awesome"
        % make the call
    ;true ->
        FirstNode = spawn(pushSumActor, start,[NumNodes]),
        makeNodes(NumNodes -1, [FirstNode],Algorithm),
        FirstNode ! {0,0}
    end.