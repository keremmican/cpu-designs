module main (
			input clk,
			input logic ps2d, ps2c,
			output logic hsync, vsync,
			output [2:0] rgb,
			output logic ground
			);
 
//memory map is defined here
localparam    BEGINMEM = 12'h000,
              ENDMEM = 12'h7ff,
				  KBDREG = 12'h800,
              KBDSTATUS = 12'h801,
				  XPOS = 12'hb01,
				  YPOS = 12'hb02;

//  memory chip
reg [15:0] memory [0:127];

reg [15:0] bitmap_spaceship[15:0] = '{
        16'b0000000010000000,
        16'b0000000111000000,
        16'b0000000111000000,
        16'b0000000111000000,
        16'b0000000111000000,
        16'b0000001111100000,
        16'b0000011111110000,
        16'b0000111111111000,
        16'b0001111111111100,
        16'b0000000111000000,
        16'b0000000111000000,
        16'b0000000111000000,
        16'b0000000111000000,
        16'b0000001111100000,
        16'b0000011111110000,
        16'b0000000111000000
    };
	 
reg [15:0] bitmap_planet [15:0] = '{
			16'b0000000000000000,
			16'b0000001111100000,
			16'b0000011111110000,
			16'b0000111111111000,
			16'b0000111111111000,
			16'b0001111111111100,
			16'b0001111111111100,
			16'b0001111111111100,
			16'b0001111111111100,
			16'b0000111111111000,
			16'b0000111111111000,
			16'b0000011111110000,
			16'b0000001111100000,
			16'b0000000000000000,
			16'b0000000000000000,
			16'b0000000000000000
    };
 
// cpu's input-output pins
logic [15:0] data_out, data_in, kbd_in, vga_in;
logic [11:0] address;
logic memwt;

//======ss7=====
logic ackx, acky;
logic INT;    //interrupt pin
logic intack; //interrupt acknowledgement

//====== pic ===============
logic irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7;

//===============IRQ's==============
always_comb
    begin
      irq0 = 1'b0;
      irq1 = 1'b0;
      irq2 = vga_interrupt;
      irq3 = 1'b0;
      irq4 = 1'b0;
      irq5 = 1'b0;
      irq6 = 1'b0;
      irq7 = 1'b0;
   end
//we assume that the devices hold their irq until being serviced by cpu
assign INT = irq0 | irq1 | irq2 | irq3 | irq4 | irq5 | irq6 | irq7; 

logic [15:0] x_p, y_p, x_s, y_s;

vga_sync vs1(.x_planet(x_p), .y_planet(y_p), .x_ship(x_s), .y_ship(y_s),
 .clk(clk), .hsync(hsync), .vsync(vsync), .rgb(rgb), .bitmap_planet(bitmap_planet), .bitmap_spaceship(bitmap_spaceship),
 .h_reverse(h_reverse), .v_reverse(v_reverse));

keyboard kb1(.clk(clk), .ack(ackx), .dout(kbd_in), .ps2d(ps2d), .ps2c(ps2c));

vertebrate vr1 (.clk(clk),.data_in(data_in), .data_out(data_out),.address(address),.memwt(memwt), .INT(INT),.intack(intack));

//multiplexer for cpu input
always_comb
begin
ackx=0;
acky=0;
	if (intack == 0)
	begin
	acky=0;
	ackx=0;
	if ( (BEGINMEM<=address) && (address<=ENDMEM) )
        begin
            data_in=memory[address];
        end
	else if ( (address==KBDSTATUS) )
        begin
            ackx = 0;
				data_in=kbd_in;
        end
	else if ( (address==KBDREG) )
        begin
            ackx = 1;        
            data_in = kbd_in;
        end
	else
				data_in=16'hf345;
	end
         else                        //intack = 1
            begin
             if (irq0)               //highest priority interrupt is irq0
                 data_in = 16'h0;
             else if (irq1)
                 data_in = 16'h1;
             else if (irq2)
                 data_in = 16'h2;
             else if (irq3)
                 data_in = 16'h3;
             else if (irq4)
                 data_in = 16'h4;
             else if (irq5)
                 data_in = 16'h5;
             else if (irq6)
                 data_in = 16'h6;
             else                           //  irq7 
                 data_in = 16'h7;
            end
end

//multiplexer for cpu output 
always_ff @(posedge clk) //data output port of the cpu
	begin
    if (memwt)
			begin
        if ( (BEGINMEM<=address) && (address<=ENDMEM) )
            memory[address]<=data_out;
		  else if ( XPOS == address)
				x_s <= data_out;
		  else if ( YPOS == address)
				y_s <= data_out;
		end
end

logic vga_interrupt;

reg [31:0] counter;

logic h_reverse, v_reverse;

always @(posedge clk) begin
    if (counter == 999999) begin
		if (h_reverse)
			x_p <= x_p -1;
		else
			x_p <= x_p + 1;
		if (v_reverse)
			y_p <= y_p - 2;
		else
			y_p <= y_p + 2;
      counter <= 0;
    end else
      counter <= counter + 1;
  end
		        
initial 
    begin
		  x_p = 320;
		  y_p = 240;
        $readmemh("ram.dat", memory);
    end
endmodule