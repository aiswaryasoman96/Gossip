-module(twoDGrid).
-export([build/2]).

build(NumNodes,Algorithm) ->
    Dimension = floor(math:sqrt(NumNodes)) + 1,
    buildNodeList(1,1,Dimension,[],Algorithm,Dimension*Dimension).


buildNodeList(CurrentI, CurrentJ, Dimension, NodeList,_,_) when ((CurrentI > Dimension) or (CurrentJ > Dimension)) ->

    io:fwrite("Printing List ~w~n",[NodeList]),
    NodeMap = maps:from_list(NodeList),
    io:fwrite("Printing Map ~w~n",[NodeMap]),
    buildNeighbourMap(1,1,Dimension,NodeMap,[]);



buildNodeList(CurrentI, CurrentJ, Dimension, NodeList,Algorithm,Count) when ((CurrentI =< Dimension) and (CurrentJ =< Dimension)) ->
    if Algorithm == "gossip" ->
        Pid = spawn(gossip, listenToRumor,[self(),0])
    ;(Algorithm == "push-Sum") ->
        Pid = spawn(pushSum, startActor,[self(),0],Count)
    end,
    NewNodeList = NodeList ++ [{[CurrentI,CurrentJ],Pid}],
    if CurrentI == Dimension ->
            NewCurrentI = 1,
            NewCurrentJ = CurrentJ +1,
            buildNodeList(NewCurrentI,NewCurrentJ,Dimension,NewNodeList,Algorithm,Count-1)
    ;(CurrentI < Dimension) ->
            NewCurrentI = CurrentI + 1,
            NewCurrentJ = CurrentJ,
            buildNodeList(NewCurrentI,NewCurrentJ,Dimension,NewNodeList,Algorithm,Count-1)
    end.

isValid(T, Dimension) ->
    I = lists:nth(1, T),
    J = lists:nth(2, T),
    ICondition = ((I =< Dimension) and (I > 0)),
    JCondition = ((J =< Dimension) and (J > 0)),
    ICondition and JCondition.
    

buildNeighbourMap(CurrentI,CurrentJ,Dimension,NodeMap,NeighbourList) when ((CurrentI > Dimension) or (CurrentJ > Dimension)) ->
    NeighbourMap = maps:from_list(NeighbourList),
    io:fwrite("Printing Indices ~w~n",[NeighbourMap]),
    register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
    io:fwrite("~nLine Topology structuring complete"),
    StartPid = maps:get([ceil(Dimension/2),ceil(Dimension/2)],NodeMap),
    StartPid ! "Awesome";

    
buildNeighbourMap(CurrentI,CurrentJ,Dimension,NodeMap,NeighbourList) when ((CurrentI =< Dimension) and (CurrentJ =< Dimension)) -> 

    CurrentNeighbours = [[CurrentI-1,CurrentJ-1],[CurrentI-1,CurrentJ],[CurrentI-1,CurrentJ+1],
                        [CurrentI,CurrentJ-1],[CurrentI,CurrentJ+1],
                        [CurrentI+1,CurrentJ-1],[CurrentI+1,CurrentJ],[CurrentI+1,CurrentJ+1]],
    CleanNeighboursIndices = [T|| T <- CurrentNeighbours, isValid(T,Dimension) ],
    CleanNeighbourList = [maps:get(E,NodeMap)||E <- CleanNeighboursIndices,true],
    NewNeighbourList = NeighbourList ++ [{maps:get([CurrentI,CurrentJ],NodeMap), CleanNeighbourList}],
        if CurrentI == Dimension ->
            NewCurrentI = 1,
            NewCurrentJ = CurrentJ+1 ,
            buildNeighbourMap(NewCurrentI,NewCurrentJ,Dimension,NodeMap,NewNeighbourList)
    ;(CurrentI < Dimension) ->
            NewCurrentI = CurrentI+1,
            NewCurrentJ = CurrentJ,
            buildNeighbourMap(NewCurrentI,NewCurrentJ,Dimension,NodeMap,NewNeighbourList)
    end.





