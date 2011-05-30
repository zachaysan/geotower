#include<stdio.h>
#include<stdlib.h>

typedef int bool;
#define true 1
#define false 0

typedef struct {
  float x;
  float y;
} coordinate;

float square_float(float f){
  float f_sq;
  f_sq = f*f;
  return f_sq;
}

coordinate closest_coord(coordinate check_coord, coordinate grid[], int num_elems){
  coordinate closest;
  int i = 0;
  float shortest_distance_sq;
  float current_distance_sq;
  current_distance_sq = (square_float(grid[i].x - check_coord.x) + (square_float(grid[i].y - check_coord.y)));
  shortest_distance_sq = current_distance_sq;
  closest = grid[i];
  for(i = 1; i < num_elems; i++){
    current_distance_sq = (square_float(grid[i].x - check_coord.x) + (square_float(grid[i].y - check_coord.y)));
    if(current_distance_sq < shortest_distance_sq){
      shortest_distance_sq = current_distance_sq;
      closest = grid[i];
    }
  }
  return closest;
}
