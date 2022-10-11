-module(twoDGrid).
-export([build/2]).

build(Algorithm, NumNodes) ->
    Dim = floor(math:sqrt(NumNodes)),
    if Dim*Dim == NumNodes ->
        Dimension = Dim
    ;true ->
        Dimension = Dim + 1
    end,
    buildNodeList(1,1,Dimension,[],Algorithm,Dimension*Dimension).


buildNodeList(CurrentI, CurrentJ, Dimension, NodeList,Algorithm,_) when ((CurrentI > Dimension) or (CurrentJ > Dimension)) ->
    NodeMap = maps:from_list(NodeList),
    buildNeighbourMap(1,1,Dimension,NodeMap,[],Algorithm);



buildNodeList(CurrentI, CurrentJ, Dimension, NodeList,Algorithm,Count) when ((CurrentI =< Dimension) and (CurrentJ =< Dimension)) ->
    Pid = spawn(Algorithm, start,[Count]),
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
    

buildNeighbourMap(CurrentI,CurrentJ,Dimension,NodeMap,NeighbourList,Algorithm) when ((CurrentI > Dimension) or (CurrentJ > Dimension)) ->
    NeighbourMap = maps:from_list(NeighbourList),
    register(getNeighbours, spawn(main, getConnectedActors,[NeighbourMap])),
    io:fwrite(" Topology structuring complete"),
    % io:fwrite("~n~w",[NeighbourMap]),
    {WallClock1,WallClock2} = statistics(wall_clock),
    io:fwrite("~n Start time ~w and ~w", [WallClock1,WallClock2]),
    if Algorithm == "gossip"->
        StartPid = maps:get([ceil(Dimension/2),ceil(Dimension/2)],NodeMap),
        StartPid ! "Awesome"
    ;true ->
        StartPid = maps:get([1,1],NodeMap),
        StartPid ! {0,0}
    end;

    
buildNeighbourMap(CurrentI,CurrentJ,Dimension,NodeMap,NeighbourList,Algorithm) when ((CurrentI =< Dimension) and (CurrentJ =< Dimension)) -> 

    CurrentNeighbours = [[CurrentI-1,CurrentJ-1],[CurrentI-1,CurrentJ],[CurrentI-1,CurrentJ+1],
                        [CurrentI,CurrentJ-1],[CurrentI,CurrentJ+1],
                        [CurrentI+1,CurrentJ-1],[CurrentI+1,CurrentJ],[CurrentI+1,CurrentJ+1]],
    CleanNeighboursIndices = [T|| T <- CurrentNeighbours, isValid(T,Dimension) ],
    CleanNeighbourList = [maps:get(E,NodeMap)||E <- CleanNeighboursIndices,true],
    NewNeighbourList = NeighbourList ++ [{maps:get([CurrentI,CurrentJ],NodeMap), CleanNeighbourList}],
        if CurrentI == Dimension ->
            NewCurrentI = 1,
            NewCurrentJ = CurrentJ+1 ,
            buildNeighbourMap(NewCurrentI,NewCurrentJ,Dimension,NodeMap,NewNeighbourList,Algorithm)
    ;(CurrentI < Dimension) ->
            NewCurrentI = CurrentI+1,
            NewCurrentJ = CurrentJ,
            buildNeighbourMap(NewCurrentI,NewCurrentJ,Dimension,NodeMap,NewNeighbourList,Algorithm)
    end.


