
#include <iostream>
#include "CBS.h"
#include "common.h"

using namespace std;

void CBS::precompute_h_table() {
    for(int i=0; i<ins->num_agent; i++){
        cout << "precomputing for agent " << i << endl;
        Vertex goal = ins->agent_goal[i];

        ANode * root = new ANode();
        root->v = goal;
        root->g = 0;
        root->id = 0;

        boost::heap::fibonacci_heap<ANode*, boost::heap::compare<ANode::compare_node_id>> OPEN;
        vector<ANode*> track;

        int h_table_l_expanded = 0;

        h_table.push_back(map<tuple<int,int,int>,int>());
        h_table[i][root->v] = root->g;

        OPEN.push(root);
        track.push_back(root);

        while(!OPEN.empty()){
            ANode * top = OPEN.top();
            OPEN.pop();
            h_table_l_expanded++;

            vector<Neighbor_v> neighbors = ins->get_neighbors(top->v);
            for (auto n: neighbors){
                auto it = h_table[i].find(n.first);
                if (it!=h_table[i].end()){
                    continue;
                }

                ANode * child = new ANode();
                child->v = n.first;
                child->g = top->g + n.second;
                child->id = h_table_l_expanded;

                OPEN.push(child);
                track.push_back(child);

                h_table[i][child->v] = child->g;
            }

        }
        cout << "expanded nodes: " << h_table_l_expanded << endl;
        for (auto node: track){
            delete node;
        }
    }
}

void CBS::print_single_path(const Path& path){
    int t = 0;
    for (auto a : path) {
        cout << get<0>(a) << "," << get<1>(a) << " ";
        t++;
    }
    cout << endl;
};

void CBS::print_constraint(const Constraint & cons){
    printf("Constraint: agent: %d, at loc: %d,%d,%d, loc2: %d,%d,%d, t: %d, t_range: %d \n",
           get<0>(cons), get<0>(get<1>(cons)), get<1>(get<1>(cons)), get<2>(get<1>(cons)),
           get<0>(get<2>(cons)), get<1>(get<2>(cons)), get<2>(get<2>(cons)), get<3>(cons), get<4>(cons)
    );
}

void CBS::print_paths(const vector<Path>& paths) {
    int path_id = 0;
    for (Path p : paths) {
        cout << path_id << ": ";
        int t = 0;
        for (auto a : p) {
            cout << get<0>(a) << "," << get<1>(a) << " ";
            t++;
        }
        cout << endl;
        path_id++;
    }
}

void CBS::print_collision(const Collision & c){
    printf("type %d between agents %d and %d, loc1: %d,%d,%d, loc2: %d,%d,%d, at time: %d\n", get<3>(c),
           get<0>(c), get<1>(c), get<0>(get<2>(c)), get<1>(get<2>(c)), get<2>(get<2>(c)),
           get<0>(get<4>(c)), get<1>(get<4>(c)), get<2>(get<4>(c)), get<5>(c)
    );
}

vector<Path> CBS::find_solution(float w){
    boost::heap::fibonacci_heap<CBSNode*, boost::heap::compare<CBSNode::compare_node_focal>> FOCAL;
    boost::heap::fibonacci_heap<CBSNode*, boost::heap::compare<CBSNode::compare_node>> OPEN;
    vector<CBSNode*> node_track; // for memory release

    CBSNode * root = new CBSNode();
    root->id = 0;

    precompute_h_table();

    // find initial paths for each agent.
    for (int i = 0; i<ins->num_agent; i++){
        Vertex start = ins->agent_start[i];
        Vertex goal = ins->agent_goal[i];

        cout << "finding the inital path for agent " << i << endl;
        Path p = A_star_search(i, start, goal, root->paths, list<Constraint>());
        root->paths.push_back(p);

        if(p.size() == 0){
            cout << "Agent " << i << " has no valid path from its start to its goal" << endl;
            return vector<Path>();
        }
    }

    if(debug_print){
        print_paths(root->paths);
    }


    root->cost = compute_sum_of_cost(root->paths);
    root->num_conf = count_conflicts(*root);

    root->open_handle = OPEN.push(root);
    root->focal_handle = FOCAL.push(root);

    while(!FOCAL.empty()){
        int cost_old = OPEN.top()->cost;
        CBSNode* top = FOCAL.top();
        cout << " --- Expanding CBS node, id: " << top->id << " parent: " << top->parent_id << " cost: " << top->cost << " num_conf: " << top->num_conf << endl;
        FOCAL.pop();
        OPEN.erase(top->open_handle);

        h_level_expanded++;

        Collision collision;

        if(!find_conflicts(collision, top->paths)){
            cout << "Found a solution." << endl;
            print_paths(top->paths);
            return top->paths; // solution found.
        }

        if(debug_print){
            print_collision(collision);
        }



        Constraint constraints[2];

        int a1,a2,c_type,t;
        Vertex v1,v2;
        tie(a1, a2, v1, c_type, v2, t) = collision;
        Vertex dummy_v = make_tuple(-1,-1,-1);

        if (c_type == -1) { // a vertex conflict.
            constraints[0] = make_tuple(a1, v1, v2, t, -1);
            constraints[1] = make_tuple(a2, v1, v2, t, -1);
        }
        else if (c_type == -2) { // conflict with a stay-at-goal agent.
            // constriant for a1.
            Vertex v3 = make_tuple(get<0>(top->paths[a1][top->paths[a1].size()-1]), get<1>(top->paths[a1][top->paths[a1].size() - 1]), get<2>(top->paths[a1][top->paths[a1].size() - 1]));
            constraints[0] = make_tuple(a1, v3, v2, t-1, -1);

            // a2 can't be at the blocked location.
            constraints[1] = make_tuple(a2, v1, v2, t, 1);
        }
        else if (c_type == -3) { // edge collision
            constraints[0] = make_tuple(a1, v1, v2, t,-1);
            constraints[1] = make_tuple(a2, v2, v1, t,-1);
        }
        else if (c_type == -5) {
            constraints[0] = make_tuple(a1, v1, dummy_v, t, -1);
            constraints[1] = make_tuple(a2, v2, dummy_v, t - 1, -1);
        }


        // generate child nodes
        for (const auto& constraint : constraints) {
            CBSNode* child = new CBSNode(*top);
            child->constraints.push_back(constraint);

            if(debug_print){
                print_constraint(constraint);
            }


            int agent_id = get<0>(constraint);

            Vertex start = ins->agent_start[agent_id];
            Vertex goal = ins->agent_goal[agent_id];

//            print_paths(child->paths);
            if(debug_print){
                print_single_path(child->paths[agent_id]);
            }

            child->paths[agent_id] = A_star_search(agent_id, start, goal, child->paths, child->getAllConstraints());
            if(debug_print){
                print_single_path(child->paths[agent_id]);
                print_paths(child->paths);
            }

            if (child->paths[agent_id].empty()) {
                delete child;
                continue;
            }

            child->cost = compute_sum_of_cost(child->paths);

            child->num_conf = count_conflicts(*child);

            child->open_handle = OPEN.push(child);
            node_track.push_back(child);
            if (child->cost <= w * OPEN.top()->cost) {
                child->focal_handle = FOCAL.push(child);
            }
        }

        int cost_new = OPEN.top()->cost;
        for (auto node : OPEN) {
            if (w * cost_old < node->cost && w * cost_new >= node->cost) {
                node->focal_handle = FOCAL.push(node);
            }
        }
    }
    return vector<Path>();
}

bool CBS::find_conflicts(Collision& collision, vector<Path>& paths){
    for (int i = 0; i < (int)paths.size(); i++) {   // for every path
        for (int j = i + 1; j < (int)paths.size(); j++) { // for every another path
            int a1 = paths[i].size() < paths[j].size() ? i : j;
            int a2 = paths[i].size() < paths[j].size() ? j : i;
            for (int t = 0; t < (int)paths[a1].size(); t++) {
                if (paths[a1][t] == paths[a2][t]) {
                    Vertex v = make_tuple(get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]));
                    Vertex v2 = make_tuple(-1,-1,-1);
                    collision = make_tuple(a1, a2, v, -1, v2, t);
                    return true;
                }
//                else if (paths[a1][t] == paths[a2][t - 1]) {
//                    Vertex v = make_tuple(get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]));
//                    Vertex v2 = make_tuple(get<0>(paths[a2][t - 1]), get<1>(paths[a2][t - 1]), get<2>(paths[a2][t - 1]));
//                    collision = make_tuple(a1, a2, v, -5, v2, t);
//                    return true;
//                }
//                else if (paths[a1][t-1] == paths[a2][t]) {
//                    Vertex v = make_tuple(get<0>(paths[a2][t]), get<1>(paths[a2][t]), get<2>(paths[a2][t]));
//                    Vertex v2 = make_tuple(get<0>(paths[a1][t - 1]), get<1>(paths[a1][t - 1]), get<2>(paths[a1][t - 1]));
//                    collision = make_tuple(a2, a1, v, -5, v2, t);
//                    return true;
//                }
                else if (t > 0 && paths[a1][t] != paths[a1][t - 1] &&
                         paths[a1][t] == paths[a2][t - 1] && paths[a1][t - 1] == paths[a2][t]) {
                    Vertex v = make_tuple(get<0>(paths[a1][t - 1]), get<1>(paths[a1][t - 1]), get<2>(paths[a1][t - 1]));
                    Vertex v2 = make_tuple(get<0>(paths[a1][t]), get<1>(paths[a1][t]), get<2>(paths[a1][t]));
                    collision = make_tuple(a1, a2, v, -3, v2, t);
                    return true;
                }
            }
            for (int t = (int)paths[a1].size(); t < (int)paths[a2].size(); t++) {	// a1 arrives before a2.

                Vertex blocked = make_tuple(get<0>(paths[a1].back()), get<1>(paths[a1].back()), get<2>(paths[a1].back()));
                Vertex dummy_v = make_tuple(-2,-2,-2);
                if(blocked == paths[a2][t]) {
                    collision = (make_tuple(a1, a2, blocked, -2, dummy_v, t));
                    return true;
                }
            }
        }
    }
    return false;
}

int CBS::count_conflicts(const CBSNode & curr)
{
    int retVal = 0;
    auto paths = curr.paths;

    for (int i = 0; i < (int)paths.size(); i++) {   // for every path
        for (int j = i + 1; j < (int)paths.size(); j++) { // for every another path
            int a1 = paths[i].size() < paths[j].size() ? i : j;
            int a2 = paths[i].size() < paths[j].size() ? j : i;
            for (int t = 0; t < (int)paths[a1].size(); t++) {
                if (paths[a1][t] == paths[a2][t]) {
                    retVal++;
                }
//                else if (paths[a1][t] == paths[a2][t - 1]) {
//                    retVal++;
//                }
//                else if (paths[a1][t-1] == paths[a2][t]) {
//                    retVal++;
//                }
                else if (t > 0 && paths[a1][t] != paths[a1][t - 1] &&
                         paths[a1][t] == paths[a2][t - 1] && paths[a1][t - 1] == paths[a2][t]) {
                    retVal++;
                }
            }
            for (int t = (int)paths[a1].size(); t < (int)paths[a2].size(); t++) {	// a1 arrives before a2.

                Vertex blocked = make_tuple(get<0>(paths[a1].back()), get<1>(paths[a1].back()), get<2>(paths[a1].back()));
                Vertex dummy_v = make_tuple(-2,-2,-2);
                if(blocked == paths[a2][t]) {
                    retVal++;
                }
                if (blocked == paths[a2][t-1]) {
                    retVal++;
                }
            }
        }
    }
    return retVal;
}

int CBS::compute_sum_of_cost(const vector<Path>& paths) {
    int sum_of_cost = 0;
    for (auto a : paths) {
        sum_of_cost += (a.size()-1);
    }
    return sum_of_cost;
}

Path CBS::A_star_search(int agent_id, Vertex start, Vertex goal,
                        vector<Path> & paths, const list<Constraint> & constraints){
    ANode * root = new ANode();
    root->v = start;
    root->g = 0;
    root->h = get_h_value(agent_id, root->v);
    root->f = root->g + root->h;

    int earliest_goal_timestep = get_earliest_goal_timestep(agent_id, goal, constraints);
    int latest_constraint = get_latest_constraint(agent_id, constraints);

    boost::heap::fibonacci_heap<ANode*, boost::heap::compare<ANode::compare_node>> OPEN;
//    boost::heap::fibonacci_heap<ANode*, boost::heap::compare<ANode::compare_conflict>> FOCAL;
    vector<Vertex> closed;
    vector<ANode *> track;
    Path path;

    root->open_handle = OPEN.push(root);
    track.push_back(root);

    while(!OPEN.empty()){
        ANode * top = OPEN.top();
        OPEN.erase(top->open_handle);

        l_level_expanded++;

        if(top->v == goal && top->g > earliest_goal_timestep){
//            cout << "the earliest t: " << earliest_goal_timestep << endl;
            make_path(top, path);
            reverse(path.begin(),path.end());

            for(auto node:track){delete node;}
            return path;
        }

        if(top->g > get_latest_constraint(agent_id, constraints) + 2 * ins->x_size * ins->y_size){
            continue;
        }

        vector<Neighbor_v> neighbors = ins->get_neighbors(top->v);
        for(auto n: neighbors){
            if(is_constrained(agent_id, top->v, n.first, top->g+1, constraints)){
                continue;
            }

            auto it = find(closed.begin(), closed.end(), n.first);
            if(it!=closed.end()){continue;}

            ANode * child = new ANode();
            child->v = n.first;
            child->g = top->g + 1;
            child->h = get_h_value(agent_id, child->v);
            child->f = child->g + child->h;
            child->parent = top;
            child->num_conf = get_num_low_level_node_conflict(agent_id, paths, child);

            child->open_handle = OPEN.push(child);
            track.push_back(child);
            closed.push_back(child->v);
        }

    }

    return Path();
}

int CBS::get_num_low_level_node_conflict(int agent_id, vector<Path> &paths, ANode * child) {
    // compute number of the potential conflicts.
    int current_path_idx = 0;
    int num_conflicts_with_other_paths = 0;
    for(auto path: paths){
        if(current_path_idx == agent_id){continue;}
        if(path.size() == 0){continue;}

        int timestep = child->g;

        if(child->g >= path.size()){
            timestep = path.size() -1;
        }

        if(check_body_collision(path[timestep], child->v)){
            num_conflicts_with_other_paths++;
        }
        if(child->v == path[timestep-1]){
            num_conflicts_with_other_paths++;
        }
        if(child->v == path[min(timestep+1, (int)path.size()-1)]){
            num_conflicts_with_other_paths++;
        }
        current_path_idx++;
    }
    return num_conflicts_with_other_paths;
}

bool CBS::check_body_collision(Vertex v1, Vertex v2) {
    if (abs(get<0>(v1) - get<0>(v2)) < toio_size
            && abs(get<1>(v1) - get<1>(v2)) < toio_size
               && abs(get<2>(v1) - get<2>(v2)) < toio_size) {
        return true;
    }
    return false;
}

bool CBS::is_constrained(int agent_id, Vertex curr_v, Vertex next_v, int next_t, const list<Constraint>& constraints) const {
    int a, t, t_r;
    Vertex v1, v2;
    for (const auto& c : constraints) {
        tie(a, v1, v2, t, t_r) = c;
        if (a != agent_id)
            continue;
        else if (get<0>(v2) == -2 && t_r == 1) {  // goal constraint
            if (v1 == next_v)
                return true;
        }
        else if (get<0>(v2) == -1) {  // vertex constraint
            if (v1 == next_v && t == next_t)
                return true;
        }
        else { // edge constraint
            if (curr_v == v1 && next_v == v2 && t == next_t)
                return true;
        }
    }
    return false;
}


void CBS::make_path(ANode* goal, Path& path)
{
    ANode* curr = goal;
    while (curr != nullptr) {
        path.push_back(curr->v);
        curr = curr->parent;
    }
}

int CBS::get_h_value(int a_i, Vertex v) {
    return h_table[a_i][v];
}

int CBS::get_earliest_goal_timestep(int agent_id, Vertex goal, const list<Constraint>& constraints) {
    int a, t, t_r;
    Vertex v1, v2;
    int output = -1;

    for (const auto& c : constraints) {
        tie(a, v1, v2, t, t_r) = c;
//        cout << "low level constraint check: \n";
//        print_constraint(c);
//        cout << "a: " << a << " agent: " << agent_id << endl;
//        cout << get<0>(goal) << " , " << get<1>(goal) << " , " << get<2>(goal) << endl;
        if (a == agent_id && v1 == goal && get<0>(v2) <0 && t > output) {
            output = t;
        }
    }
    return output;
}

int CBS::get_latest_constraint(int agent_id, const list<Constraint>& constraints) const {
    int a, t, t_r;
    Vertex v1,v2;
    int output = -1;
    for (const auto& c : constraints) {
        tie(a, v1, v2, t, t_r) = c;
        if (a == agent_id && t > output){
            output = t;
        }
    }
    return output;
}