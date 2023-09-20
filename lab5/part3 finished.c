/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
	
// Begin part3.c code for Lab 7
void wait_for_vsync();
void swap(int* a, int* b);
void clear_screen();
void plot_pixel(int x, int y, short int line_color);
void draw_line(int x0, int y0, int x1, int y1, short int line_color);
void draw_box(int x, int y, short int line_color);

volatile int pixel_buffer_start; // global variable
//int randx[7] = {122, 266, 320, 167, 102, 146, 229, 232};
//int randy[7] = {0, 180, 112, 146, 2, 37, 87, 191};

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
	int color_list[] = {WHITE, YELLOW, RED, GREEN, BLUE, CYAN, MAGENTA, GREY, PINK, ORANGE};
	int x_box[8];
	int y_box[8];
	int dx_box[8];
	int dy_box[8];
	int color[8];
    // initialize location and direction of rectangles(not shown)
	//srand(time(NULL));// seed the random number generator
	for(int i=0; i<8; ++i){
		x_box[i] = rand()%319; // generate a random number between 0-319
		y_box[i] = rand()%239; // generate a random number between 0-239
	}
	for(int i=0; i<8; i++){
		dx_box[i] = (rand()%2)*2 - 1; // generate either 1 or -1
		dy_box[i] = (rand()%2)*2 - 1; // generate either 1 or -1
	}
	//initialize color of the box
	for(int i=0; i<8; ++i){
		int index = rand()%10;
		color[i] = color_list[index];
	}
	
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer
	
	int tempx1[8] = {0};
	int tempy1[8] = {0};
	int tempx2[8] = {0};
	int tempy2[8] = {0};
	
    while (1){
        /* Erase any boxes and lines that were drawn in the last iteration */
			for(int i=0; i<8; ++i){
				int x1 = tempx1[(i+1)%8];
				int y1 = tempy1[(i+1)%8];
				draw_box(tempx1[i], tempy1[i], 0x000);
				draw_line(tempx1[i], tempy1[i], x1, y1, 0x000);
		 	}
		//pixel_buffer_start = *pixel_ctrl_ptr; 
        // code for drawing the boxes and lines (not shown)
			for(int i=0; i<8; ++i){
				int x = x_box[i];
				int y = y_box[i];
				int c = color[i];
				int x1 = x_box[(i+1)%8];
				int y1 = y_box[(i+1)%8];
				tempx1[i] = x_box[i];
				tempy1[i] = y_box[i];
				draw_box(x, y, c);
				draw_line(x, y, x1, y1, c);
		 	}
        // code for updating the locations of boxes (not shown)
			for(int i=0; i<8; ++i){
				x_box[i] = x_box[i]+dy_box[i];
				y_box[i] = y_box[i]+dx_box[i];
				if(x_box[i] == 0 || x_box[i] == 319){
					dy_box[i] = -1*dy_box[i];
				}
				if(y_box[i] == 0 || y_box[i] == 239){
					dx_box[i] = -1*dx_box[i];
				}
			}
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
			
			for(int i=0; i<8; ++i){
				int x1 = tempx2[(i+1)%8];
				int y1 = tempy2[(i+1)%8];
				draw_box(tempx2[i], tempy2[i], 0x000);
				draw_line(tempx2[i], tempy2[i], x1, y1, 0x000);
		 	}
			
			for(int i=0; i<8; ++i){
					int x = x_box[i];
					int y = y_box[i];
					int c = color[i];
					int x1 = x_box[(i+1)%8];
					int y1 = y_box[(i+1)%8];
					tempx2[i] = x_box[i];
					tempy2[i] = y_box[i];
					draw_box(x, y, c);
					draw_line(x, y, x1, y1, c);
			}

			for(int i=0; i<8; ++i){
					x_box[i] = x_box[i]+dy_box[i];
					y_box[i] = y_box[i]+dx_box[i];
					if(x_box[i] == 0 || x_box[i] == 319){
						dy_box[i] = -1*dy_box[i];
					}
					if(y_box[i] == 0 || y_box[i] == 239){
						dx_box[i] = -1*dx_box[i];
					}
			}
		wait_for_vsync();
		pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
		}
}

// code for subroutines (not shown)

/* Wait for Synchronization Subroutine */
void wait_for_vsync(){
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020; // pixel controller get the base address of DMA
	register int status;
	
	*pixel_ctrl_ptr = 1; // start the synchronication process
	
	status = *(pixel_ctrl_ptr + 3); // read status register at 0xFF20302c
	while((status & 0x01) != 0){
		status = *(pixel_ctrl_ptr +3); //swap
	}
}

/* Swap Subroutine */
void swap(int* a, int* b){
	int temp = *a;
	*a = *b;
	*b = temp;
}

/* Clear Screen Subroutine */
void clear_screen(){
	for(int x=0; x<319; ++x){
		for(int y=0; y<239; ++y){
			*(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = 0x0;
		}
	}
}

/* Plot pixel Subroutine */
void plot_pixel(int x, int y, short int line_color){
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

/* Draw Line Subroutine */
void draw_line(int x0, int y0, int x1, int y1, short int line_color){
	bool is_steep = abs(y1-y0) > abs(x1-x0);
	if(is_steep){
		swap(&x0, &y0);
		swap(&x1, &y1);
	}
	if(x0 > x1){
		swap(&x0, &x1);
		swap(&y0, &y1);
	}	
	int deltax = x1 - x0;
	int deltay = abs(y1 - y0);
	int error = -(deltax/2);
	int y = y0;
	int y_step;
	if(y0 < y1){
		y_step = 1;
	}else{
		y_step = -1;
	}
	
	for(int x=x0; x<=x1; ++x){
		if(is_steep){
			plot_pixel(y, x, line_color);
		}else{
			plot_pixel(x, y, line_color);
		}
		error = error + deltay;
		if(error>=0){
			y = y + y_step;
			error = error - deltax;
		}
	}
}

/* Draw box Subroutine(2x2 pixels) */
void draw_box(int x, int y, short int line_color){
	/*if(x == 319 && y != 239){
		plot_pixel(x, y, line_color);
		plot_pixel(x, y+1, line_color);
		plot_pixel(x-1, y, line_color);
		plot_pixel(x-1, y+1, line_color);
	}else if(y == 239 && x != 319){
		plot_pixel(x, y, line_color);
		plot_pixel(x, y-1, line_color);
		plot_pixel(x+1, y, line_color);
		plot_pixel(x+1, y-1, line_color);
	}else if(x == 319 && y == 239){
		plot_pixel(x, y, line_color);
		plot_pixel(x, y-1, line_color);
		plot_pixel(x-1, y, line_color);
		plot_pixel(x-1, y-1, line_color);
	}else{*/
		plot_pixel(x, y, line_color);
		plot_pixel(x, y+1, line_color);
		plot_pixel(x+1, y, line_color);
		plot_pixel(x+1, y+1, line_color);
	//}
}




