-module(imp3D).
-export([build/2]).

build(Algorithm, NumNodes) ->
    Dim = floor(math:pow(NumNodes,1/3)),
    if Dim*Dim*Dim == NumNodes ->
        Dimension = Dim
    ;true ->
        Dimension = Dim + 1
    end,
    buildNodeList(1,1,1,Dimension,[],Algorithm,Dimension*Dimension*Dimension,true).

buildNodeList(_, _, _,Dimension, NodeList,Algorithm,_,Validity) when Validity == false ->
    io:fwrite("Printing Final Node List ~w~n",[NodeList]),
    NodeMap = maps:from_list(NodeList),
    io:fwrite("Printing Node Map ~w~n",[NodeMap]),
    buildNeighbourMap(1,1,1,Dimension,NodeMap,[],Algorithm,true);


buildNodeList(CurrentI, CurrentJ,CurrentK, Dimension, NodeList,Algorithm,Count,Validity) when Validity == true ->
    Pid = spawn(Algorithm, start,[Count]),
    NewNodeList = NodeList ++ [{[CurrentI,CurrentJ,CurrentK],Pid}],
    NewCoords = getNextCoordinate(CurrentI, CurrentJ,CurrentK, Dimension),
    NewCurrentI = lists:nth(1, NewCoords),NewCurrentJ= lists:nth(2, NewCoords),NewCurrentK=lists:nth(3, NewCoords),
    NewValidity = ((NewCurrentI =< Dimension) and (NewCurrentJ =< Dimension)and (NewCurrentK =< Dimension)),
    io:fwrite("Node List ~w~n",[NewNodeList]),
    buildNodeList(NewCurrentI,NewCurrentJ,NewCurrentK,Dimension,NewNodeList,Algorithm,Count-1,NewValidity).
    

getNextCoordinate(CurrentI, CurrentJ,CurrentK, Dimension) ->
    if CurrentJ < Dimension ->
        if CurrentK < Dimension ->
            NewCurrentI = CurrentI,
            NewCurrentJ = CurrentJ,
            NewCurrentK = CurrentK + 1
        ;true ->
            NewCurrentI = CurrentI,
            NewCurrentJ = CurrentJ +1,
            NewCurrentK = 1
        end
    ;true ->
        if CurrentK < Dimension ->
            NewCurrentI = CurrentI,
            NewCurrentJ = CurrentJ,
            NewCurrentK = CurrentK + 1
        ;true ->
            NewCurrentI = CurrentI +1,
            NewCurrentJ = 1,
            NewCurrentK = 1
        end
    end,
    [NewCurrentI,NewCurrentJ,NewCurrentK].


isValid(T, Dimension) ->
    I = lists:nth(1, T),
    J = lists:nth(2, T),
    K = lists:nth(3, T),
    ICondition = ((I =< Dimension) and (I > 0)),
    JCondition = ((J =< Dimension) and (J > 0)),
    KCondition = ((K =< Dimension) and (K > 0)),
    ICondition and JCondition and KCondition.
    

buildNeighbourMap(_,_,_,Dimension,NodeMap,NeighbourList,Algorithm,Validity) when Validity == false ->
    NeighbourMap = maps:from_list(NeighbourList),
    io:fwrite("Printing Indices ~w~n",[NeighbourMap]),
    register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
    io:fwrite(" Topology structuring complete"),
    Indices = [rand:uniform(Dimension),rand:uniform(Dimension),rand:uniform(Dimension)],
    StartPid = maps:get(Indices,NodeMap),   
    io:fwrite("Final NeighbourMap List ~w~n",[NeighbourMap]),
    if Algorithm == "gossip"->
        StartPid ! "Awesome"
    ;true ->
        StartPid ! {0,0}
    end;

    
buildNeighbourMap(CurrentI,CurrentJ,CurrentK,Dimension,NodeMap,NeighbourList,Algorithm,Validity) when Validity ==true -> 

    CurrentNeighbours = [[CurrentI-1,CurrentJ-1,CurrentK],[CurrentI-1,CurrentJ,CurrentK],[CurrentI-1,CurrentJ+1,CurrentK],
                        [CurrentI,CurrentJ-1,CurrentK],[CurrentI,CurrentJ+1,CurrentK],
                        [CurrentI+1,CurrentJ-1,CurrentK],[CurrentI+1,CurrentJ,CurrentK],[CurrentI+1,CurrentJ+1,CurrentK]],
    NextPlaneNeighbours = [[lists:nth(1, T),lists:nth(2, T),CurrentK-1] || T <- CurrentNeighbours,isValid([lists:nth(1, T),lists:nth(2, T),CurrentK-1],Dimension)]
                        ++ [[lists:nth(1, T),lists:nth(2, T),CurrentK+1] || T <- CurrentNeighbours,isValid([lists:nth(1, T),lists:nth(2, T),CurrentK+1],Dimension)],
    Len = length(NextPlaneNeighbours),
    Nth = rand:uniform(Len),
    RandomNextPlaneNeighbourIndex = lists:nth(Nth, NextPlaneNeighbours),
    RandomNextPlaneNeighbour = maps:get(RandomNextPlaneNeighbourIndex,NodeMap),
    CleanNeighboursIndices = [T|| T <- CurrentNeighbours, isValid(T,Dimension) ],
    CleanNeighbourList = [maps:get(E,NodeMap)||E <- CleanNeighboursIndices,true],
    TotalNeighbours = CleanNeighbourList ++ [RandomNextPlaneNeighbour],
    NewNeighbourList = NeighbourList ++ [{maps:get([CurrentI,CurrentJ,CurrentK],NodeMap), TotalNeighbours}],
    NewCoords = getNextCoordinate(CurrentI, CurrentJ,CurrentK, Dimension),
    NewCurrentI = lists:nth(1, NewCoords),NewCurrentJ= lists:nth(2, NewCoords),NewCurrentK=lists:nth(3, NewCoords),
    NewValidity = ((NewCurrentI =< Dimension) and (NewCurrentJ =< Dimension)and (NewCurrentK =< Dimension)),
    io:fwrite("NeighbourMap List ~w~n",[NewNeighbourList]),
    buildNeighbourMap(NewCurrentI,NewCurrentJ,NewCurrentK,Dimension,NodeMap,NewNeighbourList,Algorithm,NewValidity).


