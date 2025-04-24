`timescale 1ns / 1ps



module Paddle#(parameter xloc_start=100,
	      parameter yloc_start=460
	      
	      )
(
    input up,left,right,down,
    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input	     empty, // is this pixel empty
    input	     move, // signal to update the location of the ball
    output	     draw_ball, // is the ball being drawn here?
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc // y-location of the ball
    );
    
    reg [10:0]			 occupied_lft;
   reg [10:0]			 occupied_rgt;
   reg [10:0]			 occupied_bot;
   reg [10:0]			 occupied_top;
   reg				 xdir, ydir;
   reg				 update_neighbors;

   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   wire  [3:0]            direction; 
   
   assign direction = {up,down,left,right};
   
   // are we pointing at a pixel in the ball?
   // this will make a square ball...
   assign draw_ball = (hcount <= xloc+4) & (hcount >= xloc-4) & (vcount <= yloc+4) & (vcount >= yloc-4) ?  1 : 0;

   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 9'b0;
	   occupied_rgt <= 9'b0;
	   occupied_bot <= 9'b0;
	   occupied_top <= 9'b0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	   if (update_neighbors) begin
	      occupied_lft <= 9'b0;
	      occupied_rgt <= 9'b0;
	      occupied_bot <= 9'b0;
	      occupied_top <= 9'b0;
	   end else if (~empty) begin
	      if (vcount >= yloc-5 && vcount <= yloc+5) 
		if (hcount == xloc+5)
		  occupied_rgt[(yloc-vcount+5)] <= 1'b1;  // LSB is at bottom
		else if (hcount == xloc-5)
		  occupied_lft[(yloc-vcount+5)] <= 1'b1;
	      
	      if (hcount >= xloc-5 && hcount <= xloc+5) 
		if (vcount == yloc+5)
		  occupied_bot[(xloc-hcount+5)] <= 1'b1;  // LSB is at right
		else if (vcount == yloc-5)
		  occupied_top[(xloc-hcount+5)] <= 1'b1;
	   end
	end
     end
     
     
     
     
     
     
     
     
     	      

   assign blk_lft_up = |occupied_lft[9:8];  // upper left pixels are blocked
   assign blk_lft_dn = |occupied_lft[8:7];  // lower left pixels are blocked
   assign blk_rgt_up = |occupied_rgt[9:8];  // upper right pixels are blocked
   assign blk_rgt_dn = |occupied_rgt[8:7];  // lower right pixels are blocked

   assign blk_up_lft = |occupied_top[9:8];  // left-side top pixels are blocked
   assign blk_up_rgt = |occupied_top[8:7];  // right-side top pixels are blocked
   assign blk_dn_lft = |occupied_bot[9:8];  // left-side bottom pixels are blocked
   assign blk_dn_rgt = |occupied_bot[8:7];  // right-side bottom pixels are blocked

   assign corner_lft_up = occupied_lft[10] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
   assign corner_rgt_up = occupied_rgt[10] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
   assign corner_lft_dn = occupied_lft[0] & ~blk_dn_lft & ~blk_lft_dn;   // only left bottom corner is blocked
   assign corner_rgt_dn = occupied_rgt[0] & ~blk_dn_rgt & ~blk_rgt_dn;   // only right bottom corner is blocked
   









   
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   xloc <= xloc_start;
	   yloc <= yloc_start;
	  
	   update_neighbors <= 0;
	end else if (pixpulse) begin
	   update_neighbors <= 0; // default
	   if (move) begin

	      case (direction)
		4'b0000: begin  
		   xloc <= xloc;
		   yloc <= yloc;
		end
		
		
		4'b1000: begin  
		   if (blk_up_lft | corner_lft_up |corner_rgt_up | blk_up_rgt ) begin
		      yloc <= yloc;
		      xloc <= xloc;
		      
		   end else
		   yloc <= yloc - 1;
		   
		end
		
		
		
		
		
		4'b0100: begin //moving down 
		if (blk_dn_lft | blk_dn_rgt |corner_lft_dn | corner_rgt_dn ) begin
		      yloc <= yloc;
		      xloc <= xloc;
		      
		   end else 
		   yloc <= yloc + 1;
		end
		
		
		
		
		
		
		
		4'b0010: begin
		if (blk_lft_up | blk_lft_dn |corner_lft_up | corner_lft_dn ) begin
		      yloc <= yloc;
		      xloc <= xloc;
		      
		   end else  
		 xloc <= xloc - 1;  
		   
		   
		end
		
		
		
		
		
		4'b0001: begin 
		 if (blk_rgt_up | blk_rgt_dn |corner_rgt_up | corner_rgt_dn ) begin
		      yloc <= yloc;
		      xloc <= xloc;
		      
		   end else
		 xloc <= xloc + 1;  
		   
		   
		end
		
		
	      endcase 

	      update_neighbors <= 1;
	   end 
	end 
     end
    
endmodule
