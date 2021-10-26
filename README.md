# global-deadlock-detection
This project simulates a [Wait-For-Graph](https://en.wikipedia.org/wiki/Wait-for_graph) given as input by running several processes that are dependent on each other in accordance with the input wait-for graph. It then runs a global deadlock detection algorithm on these processes, and returns whether or not the processes are in a state of deadlock. 

The key idea in a global deadlock detection algorithm is to somehow capture a snapshot of the wait-for graph, and examine it for deadlocks. The process of capturing this snapshot is distributed among various nodes. 

Two deadlock detection algorithms are implemented in this repository: The Kshemkalyani-Singhal algorithm, and the Deng-Attie-Sun algorithm. Details of these algorithms are available in the (report)[https://github.com/Tinkidinki/global-deadlock-detection/blob/master/report.pdf]. 

Instructions to run the Kshemkalyani-Singhal algorithm are given below:
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

Example input

For the graph: 1 -> 2 -> 3, we have:

```
3
2
1 1 0
1 2
2 3
1
```
