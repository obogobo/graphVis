int squareCells, cellSize, sourceCell, sinkCell;
HashMap<Integer, PVector> uiNodeMap;
int[] mouseCoords = new int[2];
Graph G = new Graph();
List<Graph.Vertex> path;

/*
 *  mouse related activities
 */
void updateCursor() {
  mouseCoords[0] = floor(mouseX / cellSize);
  mouseCoords[1] = floor(mouseY / cellSize);
  
  if (inBounds(mouseCoords[0], mouseCoords[1])) {
    sourceCell = getId(mouseCoords[0], mouseCoords[1]);
  }
}

void toggleCell() {
  Graph.Vertex v = G.getVertex(sourceCell);
  
  if (v != null) {
    v.disabled = (mouseButton == LEFT ? true : false);
  } 
}

void mouseClicked() {
  updateCursor();
  toggleCell();
}

void mouseDragged() {
  updateCursor();
  toggleCell();
}

void mouseMoved() {
  updateCursor();
  
  G.initialize(sourceCell);
  G.dijkstra(sourceCell);
  path = G.pathTo(sinkCell);
  frame.setTitle(path.size() + " cells");
}

/*
 * helper functions, ui <-> graph mapping
 */
boolean inBounds(int x, int y) {
  return x >= 0 && x < squareCells && y >= 0 && y < squareCells;
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
  
  // enabled -> diagonals cost more
  // disabled -> no affinity towards less ridiculous shortest paths :) 
  boolean heavyDiagonals = true;
  
  // connect adjacent grid cells
  for (int i=0; i<neighbors.length; i++) {
    Graph.Vertex v = neighbors[i];
    
    if (v != null) {
      int w = (i % 2 != 0 && heavyDiagonals ? 2 : 1); 
      G.addEdge(getId(x,y), v.id, w);
    }
  }
}

void setup() {
  squareCells = 33;
  cellSize = 17;
  
  // init cursor centered
  mouseCoords[0] = mouseCoords[1] = floor(squareCells / 2);
  sourceCell = getId(mouseCoords[0], mouseCoords[1]);
  
  size(cellSize * squareCells, cellSize * squareCells, P3D);
  colorMode(HSB, 360, 100, 100);
  
  G = new Graph();
  uiNodeMap = new HashMap<Integer, PVector>();
  
  // initialize cells
  for (int y=0; y<squareCells; y++) {
    for (int x=0; x<squareCells; x++) { 
      int id = getId(x, y);
      G.addVertex(id);
      uiNodeMap.put(id, new PVector(x,y));
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
    float hue = map(v.d, 0, 4 * sqrt(2 * pow(squareCells, 2)), 0, 360);
    
    if (v.id == sourceCell) {  // source == red
      fill(0, 100, 100);
    } else if (v.disabled) {  // disabled == black
      fill(0, 0, 0);
    } else if (G.pathTo(sinkCell).indexOf(v) > 0) {  // isOnPath(v) == inverse, brightly illuminated hue
      fill(360 - hue, 100, 100);
    } else {  // everything else == less luminous hue, illustrating distance from cursor 
      fill(hue, 75, 60); 
    }
   
   rect(uiNodeMap.get(v.id).x * cellSize, uiNodeMap.get(v.id).y * cellSize, cellSize, cellSize); 
  } 
}

