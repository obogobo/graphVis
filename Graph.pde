import java.util.HashMap;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.TreeSet;
import java.util.List;
import java.util.LinkedList;

public class Graph {
  private HashMap<Integer, Vertex> vertices;
  private HashMap<Vertex, TreeSet<Edge>> adjacency;

  // vertex, comparable s.t. heap.extractMin() returns the closest frontier vertex
  private class Vertex implements Comparable<Vertex> {
    public Integer id;
    public float d;	// best distance to
    public Vertex pi;	// predecessor node
    public boolean disabled;  

    public Vertex(int id) {
      this.id = id;
    }

    @Override
    public int compareTo(Vertex that) {
      return Float.compare(this.d, that.d);
    }

    @Override
    public String toString() {
      return String.format("(%d:%f)", id, d);
    }
  }

  // edge, comparable s.t. adjacency list is ordered by weight
  private class Edge implements Comparable<Edge> {
    public Vertex u, v;
    public int w;

    public Edge(Vertex u, Vertex v, int w) {
      this.u = u;
      this.v = v;
      this.w = w;
    }

    @Override
    public int compareTo(Edge that) {
      // don't use the default comparator since each adjacency list is a TreeSet, ordering Edges by weight,
      // returning 0 for equality implies edges of equal weight are the same, blocking addition to the set.
      return this.w <= that.w ? -1 : 1;
    }

    @Override
    public String toString() {
      return String.format("{(%d -> %d), %d}", u.id, v.id, w);
    }
  }

  public Graph() {
    vertices = new HashMap<Integer, Vertex>();
    adjacency = new HashMap<Vertex, TreeSet<Edge>>();
  }

  public Vertex getVertex(Integer id) {
    return vertices.get(id);
  }

  public Set<Vertex> getVertices() {
    return adjacency.keySet();
  }

  // returns vertices adjacent to a particular vertex
  public Set<Edge> getEdgeSet(int id) {
    return adjacency.get(getVertex(id));
  }

  public Vertex addVertex(int id) {
    if (getVertex(id) != null) {
      // throw new IllegalArgumentException(String.format("Vertex %d already exists", id));
      return null;
    } else {
      Vertex v = new Vertex(id);
      vertices.put(id, v);
      adjacency.put(v, new TreeSet<Edge>());
      return v;
    }
  }

  public Edge addEdge(int u, int v, int w) {
    Vertex U = getVertex(u), V = getVertex(v);

    if (U == null || V == null) {
      // throw new NullPointerException(String.format("No such Vertex, %d", U == null ? u : v));
      return null;
    } else {
      Edge e = new Edge(U, V, w);
      adjacency.get(U).add(e);
      return e;
    }
  }

  public void initialize(int source) {
    Vertex s = getVertex(source), v;

    for (int id : vertices.keySet()) {
      v = getVertex(id);
      v.d = Float.POSITIVE_INFINITY;
      v.pi = null;
    }

    s.d = 0;
  }

  public void dijkstra(int source) {
    PriorityQueue<Vertex> q = new PriorityQueue<Vertex>();
    Vertex u;

    // build the heap
    for (int id : vertices.keySet()) {
      q.add(getVertex(id));
    }

    // run dijkstra
    while ((u = q.poll()) != null) {
      for (Edge e : getEdgeSet(u.id)) {
        if (e.v.d > u.d + e.w && !u.disabled) {
          q.remove(e.v);
          e.v.d = u.d + e.w;
          e.v.pi = u;
          q.add(e.v);
        }
      }
    }
  }

  public List<Vertex> pathTo(int v) {
    List<Vertex> path = new LinkedList<Vertex>();

    for (Vertex u = getVertex(v); u != null; u = u.pi) {
      path.add(0, u); // generic version of addFirst
    }

    return path;
  }

  public HashMap<Vertex, TreeSet<Edge>> toGraph() {
    return adjacency;
  }

  @Override
  public String toString() {
    return adjacency.toString();
  }
}
