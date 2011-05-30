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

coordinate nth_closest_coord(coordinate check_coord, coordinate grid[], int num_elems, int elem_needed){
  float distance_sq[num_elems];
  int i = 0;
  for(i = 0; i < num_elems; i++){
    distance_sq[i] = (square_float(grid[i].x - check_coord.x) + (square_float(grid[i].y - check_coord.y)));
  }

  bool swap_flag = false;
  float swap = 0.0;
  coordinate grid_swap;
  
  for(i = 0; i < num_elems; i++){
    swap = distance_sq[i];
    swap_flag = false;
    if((distance_sq[i+1] < swap) && ((num_elems - 1) > i)){
      grid_swap = grid[i];
      grid[i] = grid[i+1];
      grid[i+1] = grid_swap;
      distance_sq[i] = distance_sq[i+1];
      distance_sq[i+1] = swap;
      swap_flag = true;
    }
    
    if(swap_flag){
      i--;
    } else {
      if(i == elem_needed){
	return grid[elem_needed];
      }
    }
  }
}
