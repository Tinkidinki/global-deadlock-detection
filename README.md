# global-deadlock-detection
Distributed Systems Final Project - Simulating deadlocks and experimenting with them

## Kshemkalyani-Singhal Algorithm

To run the algorithm:

1. Run the erlang shell

```erl```

2. Within the shell, compile the file:

```c(ks).```

3. Call main with any input file (5 example inputs are given):

```ks:main(inp3).```

Format of the input file, in each line, we have:

```
Number_of_Vertices
Number_of_edges
List of P Values for each vertex (P stands for number of resources required to start)
List of 'From' nodes for all edges
List of 'To' nodes for all edges
Initiator
```

Example

For the graph: 1 -> 2 -> 3, we have:

```
3
2
1 1 0
1 2
2 3
1
```