module segment (clk, left_btn, right_btn, display, grounds);
  output reg [6:0] display;
  output reg [3:0] grounds;
  input clk, left_btn, right_btn;
  
  reg left_btn_prev = 1'b0;
  reg right_btn_prev = 1'b0;

  reg [3:0] digit = 4'b0001;
  
  reg [6:0] d1 = 7'b0111000; // F
  reg [6:0] d2 = 7'b0111000; // 7
  reg [6:0] d3 = 7'b0111000; // 2
  reg [6:0] d4 = 7'b0110000; // A
  
  reg [3:0] b1 = 'hf; // Binary F
  reg [3:0] b2 = 'hf; // Binary 7
  reg [3:0] b3 = 'hf; // Binary 2
  reg [3:0] b4 = 'he; // Binary A
  
  reg [3:0] data [3:0];
  reg [25:0] clk1;
  reg [4:0] speed = 15;
  
  always @(posedge clk) begin
  right_btn_prev <= right_btn;
  if (right_btn == 1'b0 && right_btn_prev == 1'b1) begin
        case(speed)
            5'b01111: speed <= 5'b10011;
            5'b10011: speed <= 5'b11001;
            5'b11001: speed <= 5'b01111;
            default: speed <= 5'b01111;
        endcase
    end
  end
  
  always @(posedge clk) begin
  left_btn_prev <= left_btn;
	 
    if (left_btn == 1'b0 && left_btn_prev == 1'b1) begin
      if (b4 == 4'b1111) begin
		  b4 <= 4'b0000;
		  if (b3 == 4'b1111) begin
			  b3 <= 4'b0000;
			  if (b2 == 4'b1111) begin
				  b2 <= 4'b0000;
				  if (b1 == 4'b1111) begin
				     b1 <= 4'b0000;
				  end else begin
					  b1 <= b1 + 1;
				  end
			  end else begin
			     b2 <= b2 + 1;
			  end
		  end else begin
			  b3 <= b3 + 1;
		  end
      end else begin
        b4 <= b4 + 1;
		end
    end
  end
  
  always @(posedge clk)
	clk1 <= clk1+1;

  always @(posedge clk1[speed]) begin
    grounds <= digit;
		
		case(b4)
		'h0: d4 <= 7'b0000001;
		'h1: d4 <= 7'b1001111;
		'h2: d4 <= 7'b0010010;
		'h3: d4 <= 7'b0000110;
		'h4: d4 <= 7'b1001100;
		'h5: d4 <= 7'b0100100;
		'h6: d4 <= 7'b0100000;
		'h7: d4 <= 7'b0001111;
		'h8: d4 <= 7'b0000000;
		'h9: d4 <= 7'b0001100;
		'ha: d4 <= 7'b0001000;
		'hb: d4 <= 7'b1100000;
		'hc: d4 <= 7'b0110001;
		'hd: d4 <= 7'b1000010;
		'he: d4 <= 7'b0110000;
		'hf: d4 <= 7'b0111000;
		endcase
		
		case(b3)
		'h0: d3 <= 7'b0000001;
		'h1: d3 <= 7'b1001111;
		'h2: d3 <= 7'b0010010;
		'h3: d3 <= 7'b0000110;
		'h4: d3 <= 7'b1001100;
		'h5: d3 <= 7'b0100100;
		'h6: d3 <= 7'b0100000;
		'h7: d3 <= 7'b0001111;
		'h8: d3 <= 7'b0000000;
		'h9: d3 <= 7'b0001100;
		'ha: d3 <= 7'b0001000;
		'hb: d3 <= 7'b1100000;
		'hc: d3 <= 7'b0110001;
		'hd: d3 <= 7'b1000010;
		'he: d3 <= 7'b0110000;
		'hf: d3 <= 7'b0111000;
		endcase
		
		case(b2)
		'h0: d2 <= 7'b0000001;
		'h1: d2 <= 7'b1001111;
		'h2: d2 <= 7'b0010010;
		'h3: d2 <= 7'b0000110;
		'h4: d2 <= 7'b1001100;
		'h5: d2 <= 7'b0100100;
		'h6: d2 <= 7'b0100000;
		'h7: d2 <= 7'b0001111;
		'h8: d2 <= 7'b0000000;
		'h9: d2 <= 7'b0001100;
		'ha: d2 <= 7'b0001000;
		'hb: d2 <= 7'b1100000;
		'hc: d2 <= 7'b0110001;
		'hd: d2 <= 7'b1000010;
		'he: d2 <= 7'b0110000;
		'hf: d2 <= 7'b0111000;
		endcase
		
		case(b1)
		'h0: d1 <= 7'b0000001;
		'h1: d1 <= 7'b1001111;
		'h2: d1 <= 7'b0010010;
		'h3: d1 <= 7'b0000110;
		'h4: d1 <= 7'b1001100;
		'h5: d1 <= 7'b0100100;
		'h6: d1 <= 7'b0100000;
		'h7: d1 <= 7'b0001111;
		'h8: d1 <= 7'b0000000;
		'h9: d1 <= 7'b0001100;
		'ha: d1 <= 7'b0001000;
		'hb: d1 <= 7'b1100000;
		'hc: d1 <= 7'b0110001;
		'hd: d1 <= 7'b1000010;
		'he: d1 <= 7'b0110000;
		'hf: d1 <= 7'b0111000;
		endcase
	
	case (digit)
      4'b0001:display <= d1;
      4'b0010:display <= d2;
		4'b0100:display <= d3;
      4'b1000:display <= d4;
    endcase
        
    digit <= (digit == 4'b1000) ? 4'b0001 : digit << 1;
  end
endmodule
