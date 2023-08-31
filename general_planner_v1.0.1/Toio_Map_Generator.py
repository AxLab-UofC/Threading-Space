#!/usr/bin/env python
# coding: utf-8

import sys, getopt
import networkx as nx
import numpy as np
import os
from glob import glob
from shutil import copy
from networkx.drawing.nx_agraph import graphviz_layout
import matplotlib.pyplot as plt
import seaborn as sns
import subprocess
import time

DEBUG = False

planner_directory = "/Users/harrisondong/Desktop/axlab/Threading-Space/general_planner_v1.0.1/"
folder_path = planner_directory + "toio_map_examples" ###############################

def grid_roadmap_generation():
    x_space = x_size + x_shift
    y_space = y_size + y_shift

    vertices = {}
    plot_pos = {}
    neighbor_list = [[] for i in range(0,num_x*num_y)]
    edges_in_coord = []
    edges = []

    v_idx = 0
    for x in range(0,num_x):
        x_coord = x * x_size/num_x + x_shift
        for y in range(0, num_y):
            y_coord = y * y_size/num_y + y_shift
            print(str(x_coord) + ", " + str(y_coord))
            if(x_coord<x_space and y_coord<y_space):
                vertices[(x_coord,y_coord)] = v_idx
                plot_pos[v_idx] = (x_coord,y_coord)
                if((y_coord+y_size/num_y) < y_space):
                    edges_in_coord.append(((x_coord, y_coord),(x_coord, y_coord+y_size/num_y)))
                if((x_coord+x_size/num_x) < x_space):
                    edges_in_coord.append(((x_coord, y_coord),(x_coord+x_size/num_x, y_coord)))
            v_idx+=1

    for e_c in edges_in_coord:
        edges.append((vertices[e_c[0]], vertices[e_c[1]]))


    G = nx.Graph()

    for i in range(len(edges)):
        G.add_edge(edges[i][0], edges[i][1])

    # pos = {i: p for i,p in enumerate(vertices)}
    # print(pos)

    fig, ax = plt.subplots(figsize=(15,15))

    nx.draw(G, pos=plot_pos,node_size=15, ax=ax, with_labels = True)
    limits=plt.axis('on')
    ax.tick_params(left=True, bottom=True, labelleft=True, labelbottom=True)

    # save the grid map to a file.

    print(os.getcwd())
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

    content = []
    content.append('{},{},{},{}'.format(x_size, y_size, len(vertices), len(edges)))

    for v in vertices.items():
        content.append('{},{},{}'.format(v[1],v[0][0],v[0][1]))

    for e in edges:
        content.append('{},{}'.format(e[0],e[1]))

    # print(content)

    write_to = folder_path+"/grid_map_{}_{}_{}.txt".format(x_size,y_size,len(vertices))
    f = open(write_to, 'w')
    for c in content:
        f.write(c+"\n")
    f.close()

    return vertices, write_to


def generate_agent_random_starts_and_goals(vertices, num_instance_to_generate, num_agents):
    # generate random agent files

    for i in range(0,num_instance_to_generate):

        random_loc = np.random.choice(list(vertices.values()), num_agents * 2, replace=False)
        start_loc = random_loc[0:num_agents]
        goal_loc = random_loc[num_agents:]
        print(start_loc, goal_loc)

        content = []
        content.append('{}\n'.format(num_agents))

        for a in range(0,num_agents):
            content.append('{},{},{}\n'.format(a, start_loc[a], goal_loc[a]))

        # print(content)

        write_to = folder_path+"/grid_agent_{}_{}_{}_{}_{}.txt".format(x_size,y_size, len(vertices),num_agents, i)
        f = open(write_to, 'w')
        for c in content:
            f.write(c)
        f.close()

    return write_to


def generate_custom_agent_file(vertices, num_instance_to_generate, num_agents, start_loc, goal_loc):
    write_to = ""
    for i in range(0,num_instance_to_generate):
        content = []
        content.append('{}\n'.format(num_agents))

        for a in range(0,num_agents):
            content.append('{},{},{}\n'.format(a, start_loc[a], goal_loc[a]))

        # print(content)

        write_to = folder_path+"/grid_agent_shape_example_{}_{}_{}_{}_{}.txt".format(x_size,y_size, len(vertices),num_agents, i)
        f = open(write_to, 'w')
        for c in content:
            f.write(c)
        f.close()

    return write_to


def run_path_planner(program, map_file, agent_file, path_file):
    cpp_out = subprocess.run(program + " " + map_file + " " + agent_file + " 10 " + path_file, capture_output=True,shell=True)
    print(cpp_out.stdout.decode())
    print(cpp_out.stderr.decode())


def visualize_movements(map_file, agent_file, path_file, num_x, num_y):
    # Put the map file path in "map_file" and the agent file path in "agent_file"

    x_space = 0
    y_space = 0
    num_vertices = 0
    num_edges = 0

    # shifting the grid
    x_shift = 50
    y_shift = 50

    vertices = {}
    plot_pos = {}
    neighbor_list = [[] for i in range(0,num_x*num_y)]
    edges_in_coord = []
    edges = []

    with open(map_file, 'r') as f:
        lines = f.readlines()
        # print(lines[0].strip().split(","))
        for l_id, l in enumerate(lines):
            l_data = l.strip().split(",")
            # print(l_data)
            if(l_id == 0):
                x_space = int(l_data[0])
                y_space = int(l_data[1])
                num_vertices = int(l_data[2])
                num_edges = int(l_data[3])
            elif(l_id >0 and l_id <= num_vertices):
                v_id = int(l_data[0])
                x_coord = float(l_data[1])
                y_coord = float(l_data[2])
                vertices[(x_coord, y_coord)] = v_id
                plot_pos[v_id] = (x_coord,y_coord)
            elif(l_id > num_vertices):
                edges.append((int(l_data[0]), int(l_data[1])))

    # load start and goal locations

    agent_starts = []
    agent_goals = []

    with open(agent_file, 'r') as f:
        lines = f.readlines()
        for l in lines[1:]:
            l_data = l.strip("\n").split(",")
            # print(l_data)
            agent_starts.append(int(l_data[1]))
            agent_goals.append(int(l_data[2]))

    # Put the path to the file of paths in "path_file"

    # load paths
    print(vertices)
    paths = []
    max_length = 0
    with open(path_file, 'r') as f:
        lines = f.readlines()
        for l_id, l in enumerate(lines):
            l_data = l.strip("\n").split(" ")
            # print(l_data)
            max_length = max(max_length, len(l_data) - 1) # there is a '' at the end of array.
            path = []
            for i, v in enumerate(l_data):
                v_data = v.split(",")
                if(len(v_data)<3):
                    continue
                x = float(v_data[0])
                y = float(v_data[1])
                z = float(v_data[2])
                print(x,y,z)

                path.append(vertices[(x,y)])
            paths.append(path)

    # print(paths)

    # Plot the map and the movements.

    img_folder_path = planner_directory+"images/"
    if not os.path.exists(img_folder_path):
        os.makedirs(img_folder_path)
    else:
        for pictures in glob(planner_directory+"images/*.png"):
            os.remove(pictures)

    for t in range(0,max_length):
        labels = {}
        start_labels = {}
        goal_labels = {}
        agent_locs = []
        for p in paths:
            if(t>len(p)-1):
                agent_locs.append(p[-1])
            else:
                agent_locs.append(p[t])

        G = nx.Graph()

        for i in range(len(edges)):
            G.add_edge(edges[i][0], edges[i][1])

        for node in G.nodes():
            for i_l, loc in enumerate(agent_locs):
                if node == loc:
                    labels[node] = i_l
                    break
            for i_l, loc in enumerate(agent_starts):
                if node == loc:
                    start_labels[node] = "s_"+str(i_l)
                    break
            for i_l, loc in enumerate(agent_goals):
                if node == loc:
                    goal_labels[node] = "g_"+str(i_l)
                    break

        fig, ax = plt.subplots(figsize=(10,10))


        nx.draw(G, pos=plot_pos,node_size=15, ax=ax)
        nx.draw_networkx_labels(G,plot_pos,labels,font_size=16,font_color='r')
        # nx.draw_networkx_labels(G,plot_pos,start_labels,font_size=16,font_color='b')
        nx.draw_networkx_labels(G,plot_pos,goal_labels,font_size=10,font_color='b')


        limits=plt.axis('on')
        ax.tick_params(left=True, bottom=True, labelleft=True, labelbottom=True)


        plt.savefig(img_folder_path+str(t)+".png")


def generate_gif():
    from PIL import Image
    import os
    from IPython.display import Image as im2

    frames = [Image.open(image) for image in sorted(glob(planner_directory+'images/*.png'), key=os.path.getmtime)]
    frame_one = frames[0]
    frame_one.save(planner_directory+"movement.gif", format="GIF", append_images=frames,
                save_all=True, duration=100, loop=0)
    im2(open(planner_directory+'movement.gif','rb').read())


if __name__ == "__main__":
    # GENERATE GRAPH ROADMAP
    num_x = 0
    num_y = 0
    x_size = 0
    y_size = 0

    # shifting the grid
    x_shift = 0
    y_shift = 0

    #
    num_agents = 0
    num_instance_to_generate = 1

    # name of file with start + goal vertices
    start_filename = "start.txt"
    goal_filename = "goal.txt"

    argv = sys.argv
    argv.pop(0)
    opts, args = getopt.getopt(argv, "a:b:c:d:e:f:g:h:i:j:")

    for opt, arg in opts:
        if opt == '-a':
            num_x = int(arg)
        elif opt == '-b':
            num_y = int(arg)
        elif opt == '-c':
            x_size = int(arg)
        elif opt == '-d':
            y_size = int(arg)
        elif opt == '-e':
            x_shift = int(arg)
        elif opt == '-f':
            y_shift = int(arg)
        elif opt == '-g':
            num_agents = int(arg)
        elif opt == '-h':
            num_instance_to_generate = int(arg)
        elif opt == '-i':
            planner_directory = arg
        elif opt == '-j':
            if arg == "True":
                DEBUG = True

        
    #first_starttime = time.time()
    vertices, map_file = grid_roadmap_generation()
    #map_time = str(time.time() - first_starttime)
    
    # GENERATE AGENT FILE
    """ start_loc = range(0,30)
    goal_loc = [217,216,215,214,213,
                212,240,265,290,315,
                340,341,342,339,338,
                337,336,343,344,335,
                256,302,325,278,299,
                306,333,274,295,348
                ] """    # index of locations on the map.
    
    start_loc = []
    goal_loc = []
    # Load start locations
    with open(planner_directory + start_filename, 'r') as file1:
        toio_starts = file1.readlines()
    for toio_start in toio_starts:
        if toio_start.strip('\n') == "":
            continue
        start_loc.append(int(toio_start.strip('\n')))
    
    # Load goal locations
    with open(planner_directory + goal_filename, 'r') as file2:
        toio_goals = file2.readlines()
    for toio_goal in toio_goals:
        if toio_goal.strip('\n') == "":
            continue
        goal_loc.append(int(toio_goal.strip('\n')))

        """ print(u_v)
        print("start_loc: " + str(start_loc))
        print("goal_loc: " + str(goal_loc)) """
    # Converting vertex numbers, v, to coordinates: x = int(v / num_y) * (x_space / num_x) + x_shift
    #                                               y = v % num_y * (y_space / num_y) + y_shift
    # Converting coordinates to vertex numbers: v = ((x - x_shift) * (num_x / x_space) * num_y) + ((y - y_shift) * (num_y / y_space))

    #starttime = time.time()
    agent_file = generate_agent_random_starts_and_goals(vertices, num_instance_to_generate, num_agents)
    agent_file = generate_custom_agent_file(vertices, num_instance_to_generate, num_agents, start_loc, goal_loc)
    #agent_time = str(time.time() - starttime)


    # EXECUTE PATH PLANNER
    # Enter the location of the compiled C++ executable.
    #starttime = time.time()
    program = planner_directory+"general_planner"

    # Enter where you want to output the path file.
    path_file = planner_directory+"output_path.txt"
    run_path_planner(program, map_file, agent_file, path_file)
    #plan_time = str(time.time() - starttime)

    # VISUALIZE
    #starttime = time.time()
    if DEBUG == True:
        visualize_movements(map_file, agent_file, path_file, num_x, num_y)
        generate_gif()
    #viz_time = str(time.time() - starttime)
    #total_time = str(time.time() - first_starttime)

    """print("Map Gen Time: " + map_time)
    print("Agent Gen Time: " + agent_time)
    print("Planner Run Time: " + plan_time)
    print("Viz Time: " + viz_time)
    print("TOTAL TIME: " + total_time)"""
 


# NOTES FOR DOCUMENTATION
#   1. Set planner_directory global variable in Toio_Map_Generator.py to the directory of the general path planner folder.
#       a. May need to check working directory of the command line opened by Processing







