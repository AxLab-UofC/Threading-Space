// The general path planner for the collaboration with AxLab.
// This is an ongoing work. License will be added.
// Author: Yi Zheng, yzheng63@usc.edu

#include <iostream>
#include <boost/program_options.hpp>
#include <boost/tokenizer.hpp>

#include "CBS.h"

using namespace std;

int main(int argc, char** argv) {

    // loading program parameters.

    string map_file = argv[1];
    string agent_file = argv[2];
    int w_value = stoi(argv[3]);
    string output_file = argv[4];

    Instance * ins = new Instance();
    ins->load_map(map_file);
    ins->load_agents(agent_file);
//    ins->load_map("../examples/grid_map_1000_1000_625.txt");
//    ins->load_agents("../examples/grid_agent_shape_example_1000_1000_625_20_0.txt");

    CBS * planner = new CBS(ins);
    planner->debug_print = false;

    auto plan = planner->find_solution(w_value);

    if (plan.empty()) {
        cout << "No solution." << endl;
        return 0;
    }

    // save the paths
//    int max_length = 0;

//    for (int i = 0; i < ins->num_agent; i++) {
//        if (plan[i].size() >= max_length) {
//            max_length = plan[i].size();
//        }
//    }
    ofstream paths_output;
    paths_output.open(output_file);
    for (int i = 0; i < ins->num_agent; i++) {
        for (auto loc : plan[i]) {
            paths_output << get<0>(loc) << "," << get<1>(loc) << "," << get<2>(loc) << " ";
        }
        paths_output << endl;
    }
    paths_output.close();

    return 0;
}
