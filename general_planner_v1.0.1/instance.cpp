
#include "instance.h"

vector<Neighbor_v> Instance::get_neighbors(Vertex & v){
    return neighbors[v];
}

void Instance::load_map(string map_file){
    ifstream myfile(map_file.c_str());
    if(myfile.is_open()){
        string line;
        int line_idx = 0;
        while(getline(myfile, line)){
            vector<string> values;
            boost::split(values, line, boost::is_any_of(","));

            if(line_idx == 0){
                x_size = stoi(values[0]);
                y_size = stoi(values[1]);
                num_vertex = stoi(values[2]);
                num_edge = stoi(values[3]);
            }
            else if(line_idx>0 && line_idx <= num_vertex){
                int v_id = stoi(values[0]);
                int x = stoi(values[1]);
                int y = stoi(values[2]);
                int z = 0; // assume no z-axis movements for now.
                vertices.push_back(make_tuple(x,y,z));
                neighbors[make_tuple(x,y,z)] = vector<Neighbor_v>();
                edges.push_back(make_tuple(v_id, v_id, 1)); // stay at the same loc, cost 1.
                neighbors[make_tuple(x,y,z)].push_back(make_pair(vertices[v_id], 1));
            }
            else if(line_idx>num_vertex && line_idx <= num_vertex + num_edge){
                int n1 = stoi(values[0]);
                int n2 = stoi(values[1]);
                float cost = calculate_edge_cost(n1, n2);
                edges.push_back(make_tuple(n1,n2,cost));
                neighbors[vertices[n1]].push_back(make_pair(vertices[n2], cost));
                neighbors[vertices[n2]].push_back(make_pair(vertices[n1], cost));
            }

            line_idx++;
        }
    }
    myfile.close();
}

float Instance::calculate_edge_cost(int n1, int n2){
    return 1; // assume unit cost for now.
}

void Instance::load_agents(string agent_file){
    ifstream myfile(agent_file.c_str());
    if(myfile.is_open()){
        string line;
        int line_idx = 0;
        while(getline(myfile, line)) {
            vector<string> values;
            boost::split(values, line, boost::is_any_of(","));
            if(line_idx == 0){
                num_agent = stoi(values[0]);
            }
            else{
                int start_v_idx = stoi(values[1]);
                int goal_v_idx = stoi(values[2]);
                if(find(agent_start.begin(), agent_start.end(),vertices[start_v_idx])!= agent_start.end()){
                    cout << "No solution. Two agents have the same start location." << endl;
                    exit(0);
                }
                agent_start.push_back(vertices[start_v_idx]);

                if(find(agent_goal.begin(), agent_goal.end(),vertices[goal_v_idx])!= agent_goal.end()){
                    cout << "No solution. Two agents have the same goal location." << endl;
                    exit(0);
                }
                agent_goal.push_back(vertices[goal_v_idx]);

            }
            line_idx++;
        }
    }
    myfile.close();
}