-module(topology).

line(NumNodes) when NumNodes == 0 ->
    io:fwrite("Line Topology structuring complete");


line(NumNodes) when NumNodes > 0 ->
    io:fwrite("Spawning in Line topology").