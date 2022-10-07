-module(full).
-export([build/1, getNeighbourList/1]).

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


makeNodes(NumNodes, NodeList) when NumNodes ==0 ->
    register(getNeighbours, spawn(full, getNeighbourList,[NodeList]));

makeNodes(NumNodes, NodeList) when NumNodes > 0 ->
    NewList = NodeList ++ [spawn(gossip, listenToRumor,[self(),0])],
    makeNodes(NumNodes -1, NewList).

build(NumNodes) -> 
    FirstNode = spawn(gossip, listenToRumor,[self(),0]),
    makeNodes(NumNodes -1, [FirstNode]),
    FirstNode ! "Awesome".
    % make the call