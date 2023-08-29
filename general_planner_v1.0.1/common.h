
#ifndef GENERAL_PLANNER_COMMON_H
#define GENERAL_PLANNER_COMMON_H

using namespace std;
#include <boost/heap/fibonacci_heap.hpp>
#include <list>

typedef tuple<int,int,int> Vertex;
typedef tuple<int,int,float> Edge;
typedef pair<Vertex, float> Neighbor_v; // the neighbor Vertex and the travel cost.

typedef vector<Vertex> Path; // ignore heading direction for now.
// a_id, a_id2, locx, locy, locz, collision type ,locx2, locy2, locz2, timestep
typedef tuple<int, int, Vertex, int, Vertex, int> Collision;

// constraint, a1, x1,y1, z1, x2, y2 ,z2, t, t_ranged
typedef tuple<int, Vertex, Vertex, int, int> Constraint;


#endif //GENERAL_PLANNER_COMMON_H
