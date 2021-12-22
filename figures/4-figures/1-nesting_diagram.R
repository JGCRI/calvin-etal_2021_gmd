# *******************************************************************
# * Nesting diagram
# *
# * Description: this file reads plots the gcamland nesting diagram
# *
# * Author: Kate Calvin
# * Date: June 15, 2021
# *******************************************************************

# =========
# Read in header
source("./header.R")

# =========
# Define the nest
nodes <-
  create_node_df(n = 7,
                 label = c("root", "AgroForestLand", "AllPastureLand", "AgroForest_NonPasture", "GrassShrubLand", "AllForestLand", "CropLand"),
                 type = "node",
                 style = "filled",
                 fillcolor = "white", 
                 fontcolor = "black", 
                 fixedsize = FALSE,
                 shape= "oval")

fixed <-
  create_node_df(n=3,
                label = c("Urban", "Tundra", "RockIceDesert"),
                type = "unmanaged",
                style = "filled",
                fillcolor = "#beaed4",
                fontcolor = "black", 
                fixedsize = FALSE,
                shape= "box")

unmanaged <-
  create_node_df(n=5,
                 label = c("UnmanagedPasture", "UnmanagedForest", "Grassland", "Shrubland", "OtherArableLand"),
                 type = "unmanaged",
                 style = "filled",
                 fillcolor = "#7fc97f",
                 fontcolor = "black", 
                 fixedsize = FALSE,
                 shape= "box")

managed <-
  create_node_df(n=14,
                 label = c("Pasture", "Forest", "Corn", "FiberCrop", "MiscCrop", "OilCrop",
                           "OtherGrain", "Rice", "Root_Tuber",
                           "SugarCrop",  "Wheat", "FodderGrass", "FodderHerb", "PalmFruit"),
                 type = "managed",
                 style = "filled",
                 fillcolor = "#fdc086",
                 fontcolor = "black", 
                 fixedsize = FALSE,
                 shape= "box")

all_nodes <- combine_ndfs(nodes, fixed, unmanaged, managed)

edges_1 <- create_edge_df(from=c(1, 1, 1, 1),
                        to=c(2, 8, 9, 10),
                        arrowhead=c("none","none","none","none"),
                        arrowtail=c("none","none","none","none"),
                        color="black")

edges_2 <- create_edge_df(from=c(2, 2),
                          to=c(3, 4),
                          arrowhead=c("none","none"),
                          arrowtail=c("none","none"),
                          color="black")

edges_3 <- create_edge_df(from=c(4, 4, 4),
                          to=c(5, 6, 7),
                          arrowhead=c("none","none","none"),
                          arrowtail=c("none","none","none"),
                          color="black")

# Pasture edges
edges_5 <- create_edge_df(from=c(3, 3),
                          to=c(16, 11),
                          arrowhead=c("none","none"),
                          arrowtail=c("none","none"),
                          color="black")

# Grass / shrub
edges_6 <- create_edge_df(from=c(5, 5),
                          to=c(13, 14),
                          arrowhead=c("none","none"),
                          arrowtail=c("none","none"),
                          color="black")

edges_7 <- create_edge_df(from=c(6, 6),
                          to=c(12, 17),
                          arrowhead=c("none","none"),
                          arrowtail=c("none","none"),
                          color="black")

edges_8 <- create_edge_df(from=c(7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7),
                          to=c(15, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29),
                          arrowhead=c("none","none","none","none","none","none","none","none","none","none","none","none","none"),
                          arrowtail=c("none","none","none","none","none","none","none","none","none","none","none","none","none"),
                          color="black")

all_edges <- combine_edfs(edges_1, edges_2, edges_3, edges_5, edges_6, edges_7, edges_8)

nest <- create_graph(nodes_df=all_nodes, edges_df=all_edges, attr_theme=FALSE) %>%
              add_global_graph_attrs(attr = "overlap",  value = "false", attr_type = "graph") %>%
              add_global_graph_attrs(attr = "splines",  value = "false", attr_type = "graph") %>%
              add_global_graph_attrs(attr = "rankdir",  value = "LR", attr_type = "graph") %>%
              add_global_graph_attrs(attr = "layout",  value = "dot", attr_type = "graph")

render_graph(graph=nest)
