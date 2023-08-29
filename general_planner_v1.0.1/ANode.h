
#ifndef GENERAL_PLANNER_ANODE_H
#define GENERAL_PLANNER_ANODE_H

using namespace std;
#include "common.h"

class ANode{
public:
    Vertex v; //x,y,z
    ANode* parent = nullptr;

    int id;
    int g;  // timestep too.
    int h;
    int f;
    int num_conf;


    struct compare_node {
        bool operator()(const ANode* n1, const ANode* n2) const {
            return n1->f >= n2->f;
        }
    };

    struct compare_node_conflict {
        bool operator()(const ANode* n1, const ANode* n2) const {
            if (n1->f == n2->f) {
                return n1->num_conf >= n2->num_conf;
            }
            return n1->f >= n2->f;
        }
    };
    struct compare_node_id {
        bool operator()(const ANode* n1, const ANode* n2) const {
            return n1->id >= n2->id;
        }
    };

    boost::heap::fibonacci_heap<ANode*, boost::heap::compare<ANode::compare_node>>::handle_type open_handle;
//    boost::heap::fibonacci_heap<ANode*, boost::heap::compare<ANode::compare_conflict>>::handle_type focal_handle;


};


#endif //GENERAL_PLANNER_ANODE_H
