module vga_sync
  (input logic        clk,
   output logic       hsync,
   output logic       vsync,
	input logic [15:0] x_planet, y_planet, x_ship, y_ship,
	input logic [15:0] bitmap_planet [15:0],
	input logic [15:0] bitmap_spaceship [15:0],
	output logic h_reverse, v_reverse,
   output logic [2:0] rgb);

   logic pixel_tick, video_on;
   logic [9:0] h_count;
   logic [9:0] v_count;

   localparam HD       = 640, //horizontal display area
              HF       = 48,  //horizontal front porch
              HB       = 16,  //horizontal back porch
              HFB      = 96,  //horizontal flyback
              VD       = 480, //vertical display area
              VT       = 10,  //vertical top porch
              VB       = 33,  //vertical bottom porch
              VFB      = 2,   //vertical flyback
                  LINE_END = HF+HD+HB+HFB-1,
              PAGE_END = VT+VD+VB+VFB-1;

   always_ff @(posedge clk)
     pixel_tick <= ~pixel_tick; //25 MHZ signal is generated.


   //=====Manages hcount and vcount======
   always_ff @(posedge clk)
     if (pixel_tick) 
       begin
          if (h_count == LINE_END)
              begin
                  h_count <= 0;
                  if (v_count == PAGE_END)
                        v_count <= 0;
                  else
                     v_count <= v_count + 1;
               end
           else
               h_count <= h_count + 1;
        end
      
   //=====================color generation=================  
   //== origin of display area is at (h_count, v_count) = (0,0)===	
   always_comb begin
	 if ((x_ship <= h_count) && (h_count <= x_ship + 16) && (y_ship <= v_count) && (v_count <= y_ship + 16))
        if (bitmap_spaceship[y_ship - v_count][h_count - x_ship] == 1'b0)
		  if ((bitmap_planet[y_planet - v_count][h_count - x_planet] == 1'b1) && (x_planet <= x_ship + 8 && x_planet >= x_ship - 8) && (y_planet <= y_ship + 8 && y_planet >= y_ship - 8))
				rgb = 3'b100; //kırmızı
		  else
					rgb = 3'b010; //yeşil
        else
            rgb = 3'b110; //sarı
    else if ((x_planet <= h_count) && (h_count <= x_planet + 16) && (y_planet <= v_count) && (v_count <= y_planet + 16))
        if (bitmap_planet[y_planet - v_count][h_count - x_planet] == 1'b0)
					rgb = 3'b010;
		  else
				rgb = 3'b100;
    else if ((h_count < HD) && (v_count < VD))
        begin
            rgb = 3'b010;
        end
    else
        rgb = 3'b000;
	end
	
	always_ff @(posedge clk)
		begin
			if (x_planet >= HD - 16)
				h_reverse = 1;
			else if (x_planet <= 0)
				h_reverse = 0;
			if (y_planet >= VD - 16)
				v_reverse = 1;
			else if (y_planet <= 16)
				v_reverse = 0;
		end

   //=======hsync and vsync will become 1 during flybacks.=======
   //== origin of display area is at (h_count, v_count) = (0,0)===
   assign hsync = (h_count >= (HD+HB) && h_count <= (HFB+HD+HB-1));
   assign vsync = (v_count >= (VD+VB) && v_count <= (VD+VB+VFB-1));

   initial
     begin
        h_count = 0;
        v_count = 0;
		  h_reverse = 0;
		  v_reverse = 0;
        pixel_tick = 0;
     end
endmodule