module top
  (
    input   CLK,              // CLK
    input   i_PhotoResistor,  // PIN 14
    output  o_PRBSToLaser,    // pin 15
    output  o_Shift_0,        // pin 20
    output  o_Shift_1,        // pin 19
    output  o_Shift_2,        // pin 18
    output  o_Shift_3,        // pin 17
    output  o_TestLED,        // pin 13
  );

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

  wire w_xor;

  reg [31:0]  r_Shift = 32'b10000000000000000000000000000000;


  // Clock reduction - 16MHz/2097152 = 7.63Hz - 21 bits = 2097152

  reg [23:0]  r_ReduceCLK = 24'b000000000000000000000000;
  reg [23:0]  r_ClkLimit = 24'b000111101000010010000000; //  2097152

  always @(posedge CLK)
  begin
      if (r_ReduceCLK < r_ClkLimit)
        r_ReduceCLK <= r_ReduceCLK + 1;
      else if (r_ReduceCLK >= r_ClkLimit)
        r_ReduceCLK <= 24'b000000000000000000000000;
  end

  always @(posedge r_ReduceCLK < 1)
  begin
      r_Shift <= r_Shift << 1;
      r_Shift[0] <= w_xor; // FIX THIS, NOT UPDATING FAST ENOUGH
  end

  assign w_xor = r_Shift[0] ^ ((r_Shift[21] ^ r_Shift[31]) ^ r_Shift[1]);
  assign o_PRBSToLaser = w_xor;
  assign o_Shift_0 = r_Shift[0];
  assign o_Shift_1 = r_Shift[1];
  assign o_Shift_2 = r_Shift[2];
  assign o_Shift_3 = r_Shift[3];
  assign o_TestLED = ~i_PhotoResistor;

endmodule
