
#ifndef GENERAL_PLANNER_INSTANCE_H
#define GENERAL_PLANNER_INSTANCE_H

#include <vector>
#include <map>
#include <fstream>
#include <iostream>
#include <boost/algorithm/string.hpp>
#include "common.h"

using namespace std;

//struct Vertex{
//    int x;
//    int y;
//    int z;
//};

class Instance{
public:
    int x_size;
    int y_size;

    int num_vertex;
    int num_edge;

    vector<Vertex> vertices;
    vector<Edge> edges;
    map<Vertex, vector<Neighbor_v>> neighbors;

    int num_agent;

    vector<Vertex> agent_start;
    vector<Vertex> agent_goal;

    void load_map(string map_file);
    void load_agents(string agent_file);

    vector<Neighbor_v> get_neighbors(Vertex & v);

private:
    float calculate_edge_cost(int n1, int n2);
};



#endif //GENERAL_PLANNER_INSTANCE_H
