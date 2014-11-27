Graph G = new Graph();
List<Graph.Vertex> pathTo;
HashMap<Integer, PVector> uiNodes;
int squareCells, cellSize, sourceCell, sinkCell;
PVector currentCell;

// enable for an affinity towards less ridiculous shortest paths :)
boolean directional = false;

boolean inBounds(int x, int y) {
  return x >= 0 && x < squareCells 
      && y >= 0 && y < squareCells;
}

Integer getId(int x, int y) {
  return inBounds(x, y) ? y * squareCells + x : null;
}

void connectVertex(int x, int y) {
  Graph.Vertex[] neighbors = {  // enumreate potential neighbors (null if out of bounds)
      G.getVertex(getId(x,   y+1)), // down
      G.getVertex(getId(x+1, y+1)), // down, right
      G.getVertex(getId(x+1, y)),   // right
      G.getVertex(getId(x+1, y-1)), // up, right
      G.getVertex(getId(x,   y-1)), // up
      G.getVertex(getId(x-1, y-1)), // up, left
      G.getVertex(getId(x-1, y)),   // left
      G.getVertex(getId(x-1, y+1))  // down, left
  };
  
  // connect adjacent grid cells
  for (int i=0; i<neighbors.length; i++) {
    Graph.Vertex v = neighbors[i];
    
    if (v != null) {
      int w = (i % 2 != 0 && directional ? 2 : 1);  // directional -> diagonals cost more  
      G.addEdge(getId(x,y), v.id, w);
    }
  }
}

void setup() {
  squareCells = 53;
  cellSize = 13;
  currentCell = new PVector(floor(squareCells / 2), floor(squareCells / 2));
  sourceCell = getId((int) currentCell.x, (int) currentCell.y);
  
  size(cellSize * squareCells, cellSize * squareCells, P3D);
  colorMode(HSB, 360, 100, 100);
  
  G = new Graph();
  uiNodes = new HashMap<Integer, PVector>();
  
  // initialize cells
  for (int y=0; y<squareCells; y++) {
    for (int x=0; x<squareCells; x++) { 
      int id = getId(x, y);
      
      G.addVertex(id);
      uiNodes.put(id, new PVector(x,y));
    }
  }
  
  // interconnect grid
  for (int y=0; y<squareCells; y++) {
    for (int x=0; x<squareCells; x++) {
      connectVertex(x,y); 
    }
  }
  
  G.initialize(sourceCell);
  G.dijkstra(sourceCell);
}


void draw() {
  for (Graph.Vertex v : G.getVertices()) {
    float hue = map(v.d, 0, sqrt(1.5 * pow(squareCells, 2)), 0, 360);
    
    if (v.id == sourceCell) {
      fill(0, 100, 100);  // source == red
    } else if (G.pathTo(sinkCell).indexOf(v) > 0) {  // isOnPath(v)? inefficent... do better kid
      fill(340 - hue, 100, 100);
    } else {  // interpolate surrounding colors, invert and brighten those on pathTo
      fill(hue, 75, 60); 
    }
   
   rect(uiNodes.get(v.id).x * cellSize, uiNodes.get(v.id).y * cellSize, cellSize, cellSize); 
  } 
}

/*
 *  ui methods
 */ 
boolean cellChanged() {
  int newX = floor(mouseX / cellSize),
      newY = floor(mouseY / cellSize);
      
  if ((int) currentCell.x != newX || (int) currentCell.y != newY) {
    currentCell.x = newX;
    currentCell.y = newY;
    return true;
  }
  return false;
}

void mouseClicked() {
  sinkCell = getId((int) currentCell.x, (int) currentCell.y);
}

void mouseMoved() {
  if (cellChanged()) {
    sourceCell = getId((int) currentCell.x, (int) currentCell.y);
    
    G.initialize(sourceCell);
    G.dijkstra(sourceCell);
    pathTo = G.pathTo(sinkCell);
    
    frame.setTitle(pathTo.size() + " cells");
  }
}
