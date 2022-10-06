-module(main).
-export([start/0]).
-import_module(server).

start()->
    io:fwrite("Starting ~n"),
    Pid1 = spawn(pushSumActor, start),
    Pid2 = spawn(pushSumActor, start),
    Pid3 = spawn(pushSumActor, start),
    {Pid1} ! [Pid2,Pid3],
    {Pid2} ! [Pid1,Pid3],
    {Pid3} ! [Pid1,Pid2].
