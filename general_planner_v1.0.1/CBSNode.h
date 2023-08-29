
#ifndef GENERAL_PLANNER_CBSNODE_H
#define GENERAL_PLANNER_CBSNODE_H

#include <vector>
#include <list>
#include <boost/heap/fibonacci_heap.hpp>
#include "common.h"

using namespace std;

class CBSNode{
public:
    int id;
    int cost;
    int num_conf;
    int parent_id;
    bool root;
    const CBSNode& ptrparent;

    vector<Path> paths;

    list<Constraint> constraints;

    struct compare_node{
        bool operator()(const CBSNode* n1, const CBSNode* n2) const {
            return n1->cost >= n2->cost;
        }
    };
    struct compare_node_focal{
        bool operator()(const CBSNode* n1, const CBSNode* n2) const {
            return n1->num_conf >= n2->num_conf;
        }
    };

    boost::heap::fibonacci_heap<CBSNode*, boost::heap::compare<CBSNode::compare_node>>::handle_type open_handle;
    boost::heap::fibonacci_heap<CBSNode*, boost::heap::compare<CBSNode::compare_node_focal>>::handle_type focal_handle;

    list<Constraint> getAllConstraints() {
        list<Constraint> temp;
        for (const auto& constraint : constraints) {
            temp.push_back(constraint);
        }
        const CBSNode* curr = this;
        while (!curr->root) {
            for (const auto& constraint : curr->constraints) {
                temp.push_back(constraint);
            }
            curr = &curr->ptrparent;
        }
        return temp;
    }


    //constructors
    CBSNode(): ptrparent(*this),root(true), cost(0), id(0), num_conf(0) {}
    CBSNode(const CBSNode & parent): ptrparent(parent), root(false), parent_id(parent.id), paths(parent.paths), cost(0),
    id(parent.id + 1), num_conf(0), open_handle(nullptr), focal_handle(nullptr){}


};

#endif //GENERAL_PLANNER_CBSNODE_H
