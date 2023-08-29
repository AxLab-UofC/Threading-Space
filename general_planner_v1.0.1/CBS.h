
#ifndef GENERAL_PLANNER_CBS_H
#define GENERAL_PLANNER_CBS_H

#include "instance.h"
#include "common.h"
#include "CBSNode.h"
#include "ANode.h"

using namespace std;

class CBS {
public:

    // debug print
    bool debug_print = false;

    // stats
    int h_level_expanded = 0;
    int l_level_expanded = 0;

    Instance *ins;
    int toio_size = 20; // default value: assume it's a 20x20x20 cube.

    // data structures
    vector<std::map<Vertex, int>> h_table; // store precomputed true cost h values.

    // functions
    vector<Path> find_solution(float w); // w is the suboptimality factor.

    // Constructor
    CBS(Instance *instance) { ins = instance; };

private:
    void make_path(ANode *goal, Path &path);
    void precompute_h_table();
    int get_h_value(int a_i, Vertex v);
    int get_earliest_goal_timestep(int agent_id, Vertex goal, const list <Constraint> &constraints);
    int get_latest_constraint(int agent_id, const list <Constraint> &constraints) const;
    bool is_constrained(int agent_id, Vertex curr_v, Vertex next_v, int next_t, const list <Constraint> &constraints) const;
    bool check_body_collision(Vertex v1, Vertex v2);
    Path A_star_search(int agent_id, Vertex start, Vertex goal, vector<Path> &paths, const list <Constraint> &constraints);
    int compute_sum_of_cost(const vector<Path> &paths);
    int count_conflicts(const CBSNode &curr);
    int get_num_low_level_node_conflict(int agent_id, vector<Path> &paths, ANode *child);
    bool find_conflicts(Collision &collision, vector<Path> &paths);

    //print
    void print_collision(const Collision &c);
    void print_paths(const vector<Path> &paths);
    void print_single_path(const Path& path);
    void print_constraint(const Constraint & cons);

};
#endif //GENERAL_PLANNER_CBS_H
