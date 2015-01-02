import
  std.algorithm,
  std.array,
  std.conv,
  std.datetime,
  std.exception,
  std.file,
  std.functional,
  std.format,
  std.stdio,
  std.string;

struct Route
{
  int dest, cost;
}

struct Node
{
  Route[] neighbours;
}

alias maximize = partial!(reduce!max, 0);

Node[] readPlaces(string text) pure
{
  auto lines = splitLines(text);
  auto numNodes = lines.front.to!int;
  lines.popFront();

  Node[] nodes = new Node[](numNodes);
  foreach (lineNum, line; lines)
  {
    int node, neighbour, cost;
    line.formattedRead("%s %s %s", &node, &neighbour, &cost);
    nodes[node].neighbours ~= Route(neighbour, cost);
  }
  return nodes;
}

alias getLongestPath = memoize!getLongestPathImpl;
int getLongestPathImpl(immutable(Node[]) nodes, const int nodeID, bool[] visited)
{
              visited[nodeID] = true;
  scope(exit) visited[nodeID] = false;

  return nodes[nodeID]
    .neighbours
    .filter!(route => !visited[route.dest])
    .map!(route => route.cost + getLongestPath(nodes, route.dest, visited))
    .maximize();
}

void main()
{
  immutable nodes = readPlaces(readText("agraph"));
  auto visited = new bool[](nodes.length);
  visited[] = false;

  StopWatch sw;
  sw.start();
  int len = getLongestPath(nodes, 0, visited);
  sw.stop();

  printf("%d LANGUAGE D %d\n", len, sw.peek().msecs);
}
