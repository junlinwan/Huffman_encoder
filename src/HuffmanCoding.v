`timescale 1ns/10ps
module codenum(clk,rst_n,en_1,en_2,data_in,id0_r,id1_r,code_0,code_1,code_2,code_3,code_4,code_5,code_6,code_7,code_8,code_9);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
  input clk;
  input rst_n;
  input [3:0]data_in;
  input en_1;//使能端1，高有效时codenum模块执行计数功能
  input en_2;//使能端2，高有效时codenum模块执行频率更新功能
  input [3:0]id0_r;//接收频率最小字符，更新频率
  input [3:0]id1_r;//接收频率最次字符，更新频率
  
  output [7:0]code_0;
  output [7:0]code_1;
  output [7:0]code_2;
  output [7:0]code_3;
  output [7:0]code_4;
  output [7:0]code_5;
  output [7:0]code_6;
  output [7:0]code_7;
  output [7:0]code_8;
  output [7:0]code_9;//输出0-9字符的频率
/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/  
  reg [7:0]code_num[9:0];//记录0-9字符的频率，位宽为8;code_num为10个8位存储器
						//因为长度为256的序列，哈夫曼编码最长为8位
  parameter times_max=8'b1111_1111;//最大的频率值              
  integer i;
  
  always@(posedge clk)
    begin
      if(!rst_n)
        for(i=0;i<10;i=i+1)
          code_num[i]<=0;
      else if(en_1)//en_1有效，进行计数
    case(data_in)
		4'b0000: code_num[0]<=code_num[0]+1;
		4'b0001: code_num[1]<=code_num[1]+1;
		4'b0010: code_num[2]<=code_num[2]+1;
		4'b0011: code_num[3]<=code_num[3]+1;
		4'b0100: code_num[4]<=code_num[4]+1;
		4'b0101: code_num[5]<=code_num[5]+1;
		4'b0110: code_num[6]<=code_num[6]+1;
		4'b0111: code_num[7]<=code_num[7]+1; 
		4'b1000: code_num[8]<=code_num[8]+1;
		4'b1001: code_num[9]<=code_num[9]+1;  
    endcase
      else if(en_2)//en_2有效，更新频率
       begin
		code_num[id1_r]<=code_num[id1_r]+code_num[id0_r];//和频率存入次小值
		code_num[id0_r]<=times_max;//最大频率赋值给最小值
      end
   end				   

  assign code_0=code_num[0];
  assign code_1=code_num[1];
  assign code_2=code_num[2];
  assign code_3=code_num[3];
  assign code_4=code_num[4];
  assign code_5=code_num[5];
  assign code_6=code_num[6];
  assign code_7=code_num[7];
  assign code_8=code_num[8];
  assign code_9=code_num[9];//将存储的频率线网输出
  
endmodule
/*-----------------------------------------------------------------------
		end of model codenum
------------------------------------------------------------------------*/

module codetree(clk,rst_n,en,vic0,vic1,tree0_tmp,tree1_tmp);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
  input clk;
  input rst_n;
  input en;//编码周期有效，连接control模块的coding_sign端口
  input [3:0]vic0;
  input [3:0]vic1;//接收来自selector模块的频率最小，次小字符标号
  
  output [9:0]tree0_tmp;
  output [9:0]tree1_tmp;//输出频率最小，次小字符的树

/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/
  reg [9:0]code_tree[9:0];//记录0-9字符树的生成,10个10位的code_tree
  
  always@(posedge clk)
    begin
     if(!rst_n) 
        begin
           code_tree[0]<=10'b0000000001;
           code_tree[1]<=10'b0000000010;
           code_tree[2]<=10'b0000000100;
           code_tree[3]<=10'b0000001000;
           code_tree[4]<=10'b0000010000;
           code_tree[5]<=10'b0000100000;
           code_tree[6]<=10'b0001000000;
           code_tree[7]<=10'b0010000000;
           code_tree[8]<=10'b0100000000;
           code_tree[9]<=10'b1000000000;//树初始或为独热码形式
        end
     else if(en)//编码周期有效,将更新后的树存入"次小值"，与频率更新一致
        code_tree[vic1]<=code_tree[vic0]+code_tree[vic1];
  end
  
  assign tree0_tmp=code_tree[vic0];
  assign tree1_tmp=code_tree[vic1];//输出频率最小，次小字符的树
  
endmodule
module control(clk,rst_n,start,start_keep,coding_sign,
               pipe1,pipe2,pipe3,pipe4,pipe5,pipe6,pipe7,pipe8,
               refresh,coding_encoder,fsm_start);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/ 
  input clk;
  input rst_n;
  input start;
  
  output start_keep;//计数使能信号
  output coding_sign;//编码使能信号
  
  output reg pipe1;
  output reg pipe2;
  output reg pipe3;
  output reg pipe4;
  output reg pipe5;
  output reg pipe6;
  output reg pipe7;
  output reg pipe8;//八级流水线的使能信号
  
  output reg refresh;//用于频率，树更新使能信号
  output reg coding_encoder;//用于流水线后，encoder模块的编码使能信号
  output  fsm_start;//output模块FSM开始信号
     
  parameter times=256;//256个输入数据序列
  parameter times_code=9;//9次编码
/*------------------------------------------------------------------------
        start_keep
------------------------------------------------------------------------*/    
  reg start_reg;
  reg fsm_start_reg;
  reg [7:0]counter; 

  always@(posedge clk)
    begin
      if(!rst_n)
        start_reg<=0;
      else if(counter==times-1)
        start_reg<=0;
      else if(start)
        start_reg<=1;       
    end

  always@(posedge clk)
    begin
      if(!rst_n)
        counter<=0;
      else if(counter==times-1)
        counter<=0;
      else if(start_reg)
        counter<=counter+1;      
    end  
  
  assign start_keep=start_reg;
/*------------------------------------------------------------------------
        coding_sign
------------------------------------------------------------------------*/   
  reg [3:0]curr_st;
  reg [3:0]next_st;
  reg [7:0]counter_code;
  parameter S0=0;
  parameter S1=1;
  parameter S2=2;
  parameter S3=3;
  parameter S4=4;
  parameter S5=5;
  parameter S6=6;
  parameter S7=7;
  parameter S8=8;
  parameter S9=9;
  parameter S10=10;

  
  always@(posedge clk)
    begin
    if(!rst_n)
	curr_st<=S0;
    else
	curr_st<=next_st;
	end

  always@(posedge clk)
    begin
     if(next_st==S0)
      counter_code<=0;
     else if(next_st==S1)
      counter_code<=counter_code+1;
    end
	
  always@(*)
    case(curr_st)
     S0:
      if(counter==times-1)
        next_st=S1;
      else
        next_st=S0;	 
     S1:next_st=S2; 
     S2:next_st=S3;
     S3:next_st=S4;
     S4:next_st=S5;
     S5:next_st=S6;
     S6:next_st=S7;
     S7:next_st=S8;
     S8:next_st=S9;
     S9:next_st=S10;
     S10:
      if(counter_code==times_code)
        next_st=S0;
      else
        next_st=S1; 
     default:next_st=S0;
    endcase
  
 assign coding_sign=(curr_st==S1);  
    

/*------------------------------------------------------------------------
        fsm_start
------------------------------------------------------------------------*/  
  always@(posedge clk)
    begin
	  if(!rst_n)
        fsm_start_reg<=0;
      else if((curr_st==S10)&&(next_st==S0))
        fsm_start_reg<=1;
	  else
	    fsm_start_reg<=0;
    end	
	
assign fsm_start=fsm_start_reg; 
/*------------------------------------------------------------------------
       pipeline使能信号
------------------------------------------------------------------------*/  
  
   always@(posedge clk)
    begin
        pipe1<=coding_sign;
    end	

   always@(posedge clk)
    begin
        pipe2<=pipe1;
    end	
	
   always@(posedge clk)
    begin
        pipe3<=pipe2;
    end	
	
   always@(posedge clk)
    begin
        pipe4<=pipe3;
    end

   always@(posedge clk)
    begin
        pipe5<=pipe4;
    end	
	
   always@(posedge clk)
    begin
        pipe6<=pipe5;
    end	
	
   always@(posedge clk)
    begin
        pipe7<=pipe6;
    end	
   
   always@(posedge clk)
    begin
        pipe8<=pipe7;
    end		
		
   always@(posedge clk)
    begin
       refresh<=pipe8;
    end		
		
   always@(posedge clk)
    begin
       coding_encoder<=refresh;
    end	
	
 endmodule 
 module data_fifo ( rst, clk, rd_en, wr_en, wr_data, rd_data);
 
 parameter DEPTH=256;//fifo深度
 parameter WIDTH=4;    //fifo宽度
                                                 
 /*------------------------------------------------------------------------
         Ports
 ------------------------------------------------------------------------*/
 input                                    rst;
 input                                    clk;
 input                                    rd_en;                //fifo读使能 
 input                                    wr_en;                //fifo写使能
 input    [WIDTH-1:0]            wr_data;            //fifo读数据
 output[WIDTH-1:0]            rd_data;            //fifo写数据
 
 /*------------------------------------------------------------------------
         Internal Signal Declarations
 ------------------------------------------------------------------------*/
 reg [7:0]                      rd_ptr;              //fifo读指针
 reg [7:0]                      wr_ptr;              //fifo写指针
 reg                            rd_turn;            //fifo读指针翻转
 reg                            wr_turn;            //fifo写指针翻转
 reg [WIDTH-1:0]                rd_data_reg;    //
 reg [WIDTH-1:0]                fifo_mem [DEPTH-1:0];    //fifo存储
 integer i;
 
 
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
                 rd_ptr <= 0;
                 rd_turn <= 0;
       end
     else if (rd_en)
       begin
                 if (rd_ptr==DEPTH-1)
                     begin
                         rd_ptr <= 0;
                         rd_turn <= ~rd_turn;
                     end
                 else
                     begin
                         rd_ptr <= rd_ptr + 1;
                     end
       end
   end
 
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
                 wr_ptr <= 0;
                 wr_turn <= 0;
       end
     else if (wr_en)
       begin
                 if (wr_ptr==DEPTH-1)
                     begin
                         wr_ptr <= 0;
                         wr_turn <= ~wr_turn;
                     end
                 else
                     begin
                         wr_ptr <= wr_ptr + 1;
                     end
       end
   end  
   
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
           for(i=0;i<DEPTH;i=i+1)
                     begin
                         fifo_mem[i] <= 0; 
                     end
       end
     else if (wr_en)
       begin
           fifo_mem[wr_ptr] <= wr_data;
       end
   end
   
 always @(posedge clk or negedge rst)
   begin
     if (~rst)
       begin
           rd_data_reg <= 0;
       end
     else if (rd_en)
       begin
           rd_data_reg <= fifo_mem[rd_ptr];
       end
   end
 
 assign rd_data = rd_data_reg;  
 
 endmodule
module encoder(clk,rst_n,en,r_tree,
 tree_r0,tree_r1,codehf_0,codehf_1,codehf_2,codehf_3,codehf_4,codehf_5,codehf_6,codehf_7,codehf_8,codehf_9,
 code_length_0,code_length_1,code_length_2,code_length_3,code_length_4,code_length_5,code_length_6,code_length_7,code_length_8,code_length_9);
 /*------------------------------------------------------------------------
         Ports
 ------------------------------------------------------------------------*/
   input clk;
   input rst_n;
   input en;//编码周期有效，模块进行编码，连接连接control模块的coding_sign_tree端口
   input r_tree;//使能端，高有效时接收来自codetree模块的树信息，延迟一拍，减少延迟，连接连接control模块的coding_sign_delay9端口
   input [9:0]tree_r0;//接收来自codetree模块的最小树
   input [9:0]tree_r1;//接收来自codetree模块的次小树
   
   output [6:0]codehf_0;
   output [6:0]codehf_1;
   output [6:0]codehf_2;
   output [6:0]codehf_3;
   output [6:0]codehf_4;
   output [6:0]codehf_5;
   output [6:0]codehf_6;
   output [6:0]codehf_7;
   output [6:0]codehf_8;
   output [6:0]codehf_9;//输出0-9字符的哈夫曼编码
    
   output [2:0]code_length_0;
   output [2:0]code_length_1;
   output [2:0]code_length_2;
   output [2:0]code_length_3;
   output [2:0]code_length_4;
   output [2:0]code_length_5;
   output [2:0]code_length_6;
   output [2:0]code_length_7;
   output [2:0]code_length_8;
   output [2:0]code_length_9; //输出0-9字符的哈夫曼编码长度，到output模块以便于不定长输出
   
 /*------------------------------------------------------------------------
         Internal Signal Declarations
 ------------------------------------------------------------------------*/  
   reg [6:0]code_hoff[9:0]; //存储哈夫曼编码，位宽为7位
   reg [6:0]code_sign[9:0]; //存储code_sign编码
   reg [2:0]code_length[9:0];//存储哈夫曼编码长度
   
   reg [9:0]tree_sum;//最小树和次小数的和
   reg [9:0]tree_1;//次小树
   integer i,j;
   
 always@(posedge clk)
   begin
   if (!rst_n)
     begin
     code_hoff[0]<=7'b000_0000;
     code_hoff[1]<=7'b000_0000;
     code_hoff[2]<=7'b000_0000;
     code_hoff[3]<=7'b000_0000;
     code_hoff[4]<=7'b000_0000;
     code_hoff[5]<=7'b000_0000;
     code_hoff[6]<=7'b000_0000;
     code_hoff[7]<=7'b000_0000;
     code_hoff[8]<=7'b000_0000;
     code_hoff[9]<=7'b000_0000;//树的初始化为0，所以编码过程只用编"1"
     
     code_sign[0]<=7'b000_0001;
     code_sign[1]<=7'b000_0001;
     code_sign[2]<=7'b000_0001;
     code_sign[3]<=7'b000_0001;
     code_sign[4]<=7'b000_0001;
     code_sign[5]<=7'b000_0001;
     code_sign[6]<=7'b000_0001;
     code_sign[7]<=7'b000_0001;
     code_sign[8]<=7'b000_0001;
     code_sign[9]<=7'b000_0001;//code_sign的初始化为1，每次更新左移一位
     
     code_length[0]<=0;
     code_length[1]<=0;
     code_length[2]<=0;
     code_length[3]<=0;
     code_length[4]<=0;
     code_length[5]<=0;
     code_length[6]<=0;
     code_length[7]<=0;
     code_length[8]<=0;
     code_length[9]<=0;
     end
   else if(en)//模块进行编码
    begin
     for(i=0;i<10;i=i+1)
     if(tree_1[i]==1)     
      code_hoff[i]<=code_hoff[i]|code_sign[i];    
      
     for(j=0;j<10;j=j+1)
      if(tree_sum[j]==1)
       begin     
        code_sign[j]<=code_sign[j]<<1;
        code_length[j]<=code_length[j]+1;
       end   
    end
 end
 
 always@(posedge clk)//接收树信息，并求和树
    begin
     if(r_tree)
      begin
       tree_sum<=tree_r0+tree_r1;
       tree_1<=tree_r1;
      end
    end
 
 /*-----------------------------------------------------------------------------------------
                                     输出huffmann code
 ------------------------------------------------------------------------------------------*/
    assign codehf_0=code_hoff[0];
    assign codehf_1=code_hoff[1];
    assign codehf_2=code_hoff[2];
    assign codehf_3=code_hoff[3];
    assign codehf_4=code_hoff[4];
    assign codehf_5=code_hoff[5];
    assign codehf_6=code_hoff[6];
    assign codehf_7=code_hoff[7];
    assign codehf_8=code_hoff[8];
    assign codehf_9=code_hoff[9];
 
 /*-----------------------------------------------------------------------------------------
                                     输出huffmann length
 ------------------------------------------------------------------------------------------*/
    assign code_length_0=code_length[0];
    assign code_length_1=code_length[1];
    assign code_length_2=code_length[2];
    assign code_length_3=code_length[3];
    assign code_length_4=code_length[4];
    assign code_length_5=code_length[5];
    assign code_length_6=code_length[6];
    assign code_length_7=code_length[7];
    assign code_length_8=code_length[8];
    assign code_length_9=code_length[9];
 
 endmodule
  module Output(clk,data_in,rst_n,fsm_start,
              codehf_r0,codehf_r1,codehf_r2,codehf_r3,codehf_r4,codehf_r5,codehf_r6,codehf_r7,codehf_r8,codehf_r9,
              length_r0,length_r1,length_r2,length_r3,length_r4,length_r5,length_r6,length_r7,length_r8,length_r9,
              output_data,output_start,output_done,fifo_rd);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input clk;
input [3:0]data_in;
input rst_n;

input [6:0]codehf_r0;
input [6:0]codehf_r1;
input [6:0]codehf_r2;
input [6:0]codehf_r3;
input [6:0]codehf_r4;
input [6:0]codehf_r5;
input [6:0]codehf_r6;
input [6:0]codehf_r7;
input [6:0]codehf_r8;
input [6:0]codehf_r9;//接收来自encoder模块的哈夫曼编码


input [2:0]length_r0;
input [2:0]length_r1;
input [2:0]length_r2;
input [2:0]length_r3;
input [2:0]length_r4;
input [2:0]length_r5;
input [2:0]length_r6;
input [2:0]length_r7;
input [2:0]length_r8;
input [2:0]length_r9;//接收来自encoder模块的哈夫曼编码长度

input fsm_start;//output模块状态机开始标志，来自control模块，在编码结束后高有效

output reg output_data;//输出数据
output reg output_start;//输出开始标志
output reg output_done;//输出结束标志

output fifo_rd;//给data_fifo模块的读信号
/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/  

reg [6:0]hoff_reg; //寄存哈夫曼编码
reg [6:0]hoff_reg_d; //延迟接收的哈夫曼编码
reg [2:0]length_reg; //寄存哈夫曼编码长度
reg [2:0]length_reg_d; //延迟接收的哈夫曼编码
reg  output_start_d;//延迟输出开始标志
reg  output_done_d;//延迟输出结束标志

reg [3:0]cnt_10; //第一部分输出计数
reg [3:0]cnt_output; //不定长输出计数
reg [3:0]cnt_output_d;//不定长输出计数延迟
reg [8:0]cnt_256;//第二部分输出计数

parameter S0=3'b000;
parameter S1=3'b001;    
parameter S2=3'b010;
parameter S3=3'b011;
parameter S4=3'b100; //FSM参数设置
parameter L2=10;//表示10个字符
parameter L4=256;//表示256个输入数据序列长度


reg [2:0]curr_st;//FSM当前状态
reg [2:0]next_st;//FSM下一周期状态

always@(posedge clk)//FSM更新
  begin
   if(!rst_n)
     curr_st<=S0;
   else
     curr_st<=next_st;
  end

always@(*)//FSM更新条件
 begin
  case(curr_st)
    S0:
    begin
      if(fsm_start)//
        next_st=S1;
      else
        next_st=S0;
    end
    S1: next_st=S2;
    S2:
    begin
      if((cnt_output<length_reg-1)&&(cnt_10<=L2))
        next_st=S2;
      else if((cnt_output==length_reg-1)&&(cnt_10<L2))
        next_st=S1;
      else if((cnt_10==L2)&&(cnt_output==length_reg-1))
        next_st=S3;
      else
      next_st=S0;
    end
    S3: next_st=S4;
    S4:
    begin
      if((cnt_output<length_reg-1)&&(cnt_256<=L4))
        next_st=S4;
      else if((cnt_output==length_reg-1)&&(cnt_256<L4))
        next_st=S3;
      else if((cnt_256==L4)&&(cnt_output==length_reg-1))
        next_st=S0;
      else 
        next_st=S0;
    end
    default:next_st=S0;
   endcase
 end
/*------------------------------------------------------------------------
        第一部分输出计数
------------------------------------------------------------------------*/ 
always@(posedge clk)
  begin
   if(!rst_n)
    cnt_10<=0;
   else if((cnt_10==L2)&&(cnt_output==length_reg-1))
    cnt_10<=0; 
   else if(next_st==S1)
    cnt_10<=cnt_10+1; 
  end
  
/*------------------------------------------------------------------------
        不定长输出计数
------------------------------------------------------------------------*/   
  
 always@(posedge clk)
  begin
   if(!rst_n)
    cnt_output<=0;
   else if(cnt_output==length_reg-1)
    cnt_output<=0; 
   else if((curr_st==S2)|((curr_st==S1)&(cnt_10!=1))|((curr_st==S4)|(curr_st==S3)))
    cnt_output<=cnt_output+1;
   end
  
 always@(posedge clk)
  begin
  cnt_output_d<=cnt_output;
  end
 /*------------------------------------------------------------------------
        第二部分输出计数
------------------------------------------------------------------------*/   
  always@(posedge clk)
  begin
  if(!rst_n)
   cnt_256<=0;
  else if((cnt_256==L4)&&(cnt_output==length_reg-1))////???
   cnt_256<=0;
  else if(curr_st==S3)
   cnt_256<=cnt_256+1;  
  end
 /*------------------------------------------------------------------------
        接收哈夫曼编码
------------------------------------------------------------------------*/   
   always@(*)
   begin
    if(curr_st==S3|curr_st==S4)
      begin
       case(data_in)//来自FIFO的输入数据序列
         4'b0000: hoff_reg_d=codehf_r0;
         4'b0001: hoff_reg_d=codehf_r1;
         4'b0010: hoff_reg_d=codehf_r2;
         4'b0011: hoff_reg_d=codehf_r3;
         4'b0100: hoff_reg_d=codehf_r4;
         4'b0101: hoff_reg_d=codehf_r5;
         4'b0110: hoff_reg_d=codehf_r6;
         4'b0111: hoff_reg_d=codehf_r7;
         4'b1000: hoff_reg_d=codehf_r8;
         4'b1001: hoff_reg_d=codehf_r9;
       default: hoff_reg_d=0;
       endcase
      end
   else if(curr_st==S1|curr_st==S2)
       begin
       case(cnt_10)//用来生成0-9字符，进行第一部分输出
         4'b0001: hoff_reg_d=codehf_r0;
         4'b0010: hoff_reg_d=codehf_r1;
         4'b0011: hoff_reg_d=codehf_r2;
         4'b0100: hoff_reg_d=codehf_r3;
         4'b0101: hoff_reg_d=codehf_r4;
         4'b0110: hoff_reg_d=codehf_r5;
         4'b0111: hoff_reg_d=codehf_r6;
         4'b1000: hoff_reg_d=codehf_r7;
         4'b1001: hoff_reg_d=codehf_r8;
         4'b1010: hoff_reg_d=codehf_r9;
       default: hoff_reg_d=0;
       endcase
      end  
   else
     hoff_reg_d=0;    
   end
   
  always@(posedge clk)
    begin
      hoff_reg<=hoff_reg_d;
    end
/*------------------------------------------------------------------------
        接收哈夫曼编码长度
------------------------------------------------------------------------*/  
   always@(*)
   begin
    if(curr_st==S3|curr_st==S4)
      begin
       case(data_in)//来自FIFO的输入数据序列
         4'b0000: length_reg_d=length_r0;
         4'b0001: length_reg_d=length_r1;
         4'b0010: length_reg_d=length_r2;
         4'b0011: length_reg_d=length_r3;
         4'b0100: length_reg_d=length_r4;
         4'b0101: length_reg_d=length_r5;
         4'b0110: length_reg_d=length_r6;
         4'b0111: length_reg_d=length_r7;
         4'b1000: length_reg_d=length_r8;
         4'b1001: length_reg_d=length_r9;
         default: length_reg_d=0;
       endcase
      end
   else if(curr_st==S1|curr_st==S2)
       begin
       case(cnt_10)//用来生成0-9字符，进行第一部分输出
         4'b0001: length_reg_d=length_r0;
         4'b0010: length_reg_d=length_r1;
         4'b0011: length_reg_d=length_r2;
         4'b0100: length_reg_d=length_r3;
         4'b0101: length_reg_d=length_r4;
         4'b0110: length_reg_d=length_r5;
         4'b0111: length_reg_d=length_r6;
         4'b1000: length_reg_d=length_r7;
         4'b1001: length_reg_d=length_r8;
         4'b1010: length_reg_d=length_r9;
         default: length_reg_d=0;
       endcase
      end  
   else
   length_reg_d=0;
   end   
   
  always@(posedge clk)
    begin
     length_reg<=length_reg_d;
    end
   
 /*------------------------------------------------------------------------
       输出开始标志，结束标志
------------------------------------------------------------------------*/   
   always@(posedge clk)
    begin
     if(!rst_n)
      output_start_d<=0;
     else if(next_st==S1&&curr_st==S0)
      output_start_d<=1;
     else 
      output_start_d<=0;   
    end
   
   always@(posedge clk)
      output_start<=output_start_d;
   
   always@(posedge clk)
     begin
      if(!rst_n)
       output_done_d<=0;
      else if(next_st==S0&&curr_st==S4)
       output_done_d<=1;
      else 
       output_done_d<=0;   
     end
   always@(posedge clk)
      output_done<=output_done_d;
 /*------------------------------------------------------------------------
       输出数据
------------------------------------------------------------------------*/     
   always@(*)
      begin
       case(length_reg-cnt_output_d-1)//
         4'b0000: output_data=hoff_reg[0];
         4'b0001: output_data=hoff_reg[1];
         4'b0010: output_data=hoff_reg[2];
         4'b0011: output_data=hoff_reg[3];
         4'b0100: output_data=hoff_reg[4];
         4'b0101: output_data=hoff_reg[5];
         4'b0110: output_data=hoff_reg[6];
         default: output_data=0;
       endcase
      end

assign fifo_rd=(next_st==S3);//输出给FIFO的读使能信号

endmodule
module selector(clk,rst_n,coding_sign,pipe1,pipe2,pipe3,pipe4,pipe5,pipe6,pipe7,pipe8,code_r0,code_r1,code_r2,code_r3,code_r4,code_r5,code_r6,code_r7,code_r8,code_r9,id0,id1);
/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
  input clk;
  input rst_n;
  input coding_sign;//selector模块的使能端，在编码周期里执行选择功能
  input pipe1;
  input pipe2;
  input pipe3;
  input pipe4;
  input pipe5;
  input pipe6;
  input pipe7;
  input pipe8;//实现流水线的控制信号，接control模块的pipe1-pipe8端口
  
  input [7:0]code_r0;
  input [7:0]code_r1;
  input [7:0]code_r2;
  input [7:0]code_r3;
  input [7:0]code_r4;
  input [7:0]code_r5;
  input [7:0]code_r6;
  input [7:0]code_r7;
  input [7:0]code_r8;
  input [7:0]code_r9;//接收0-9字符频率端口，接codenum模块的code_1-code_9端口
  
  output  [3:0]id0;
  output  [3:0]id1;//输出频率最小，次小字符标号
/*------------------------------------------------------------------------
        Internal Signal Declarations
------------------------------------------------------------------------*/ 
  reg [7:0]code_num_tmp[3:0];//比较过程中用的寄存器
  reg [3:0]code_idx[5:0];//比较过程中用的寄存器  
  reg [7:0]code_num_1[9:0]; //求次小值存储频率
  
/*------------------------------------------------------------------------
        求最小，次小频率：此部分做的优化是，将合并的概率放在"次小频率上"，可以获得较小的码方差。
------------------------------------------------------------------------*/ 
 
  always@(posedge clk)
  begin
  
    if(coding_sign)//编码过程中有效
	 begin
		code_num_tmp[0]<=(code_r0>=code_r1)?code_r1:code_r0;
		code_num_tmp[1]<=(code_r2>=code_r3)?code_r3:code_r2;
		code_num_tmp[2]<=(code_r4>=code_r5)?code_r5:code_r4;
		code_num_tmp[3]<=(code_r6>=code_r7)?code_r7:code_r6;
		code_idx[0]<=(code_r0>=code_r1)?1:0;
		code_idx[1]<=(code_r2>=code_r3)?3:2;
		code_idx[2]<=(code_r4>=code_r5)?5:4;
		code_idx[3]<=(code_r6>=code_r7)?7:6;
     end
  
    else if(pipe1)//第一级流水
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_num_tmp[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_num_tmp[3]:code_num_tmp[2];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];
		code_idx[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_idx[3]:code_idx[2];  
     end
  
    else if(pipe2)//第二级流水
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];
		code_num_tmp[1]<=(code_r8>=code_r9)?code_r9:code_r8;//10个数比较最后一个，可以放到流水线的第二级
		code_idx[1]<=(code_r8>=code_r9)?9:8;//
     end
  
    else if(pipe3)//第三级流水
		code_idx[4]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0]; 
 
    else if(pipe4)//第四级流水 
     begin  
		code_num_1[0]<=(id0==0)?8'b1111_1111:code_r0;  
		code_num_1[1]<=(id0==1)?8'b1111_1111:code_r1; 
		code_num_1[2]<=(id0==2)?8'b1111_1111:code_r2; 
		code_num_1[3]<=(id0==3)?8'b1111_1111:code_r3; 
		code_num_1[4]<=(id0==4)?8'b1111_1111:code_r4; 
		code_num_1[5]<=(id0==5)?8'b1111_1111:code_r5; 
		code_num_1[6]<=(id0==6)?8'b1111_1111:code_r6; 
		code_num_1[7]<=(id0==7)?8'b1111_1111:code_r7; 
		code_num_1[8]<=(id0==8)?8'b1111_1111:code_r8; 
		code_num_1[9]<=(id0==9)?8'b1111_1111:code_r9;//将最小值换为频率最大值，再次重复计算   
     end
  
    else if(pipe5)//第五级流水，五到八级流水求次小值，复用code_num_tmp和code_idx资源
	 begin
		code_num_tmp[0]<=(code_num_1[0]>=code_num_1[1])?code_num_1[1]:code_num_1[0];
		code_num_tmp[1]<=(code_num_1[2]>=code_num_1[3])?code_num_1[3]:code_num_1[2];
		code_num_tmp[2]<=(code_num_1[4]>=code_num_1[5])?code_num_1[5]:code_num_1[4];
		code_num_tmp[3]<=(code_num_1[6]>=code_num_1[7])?code_num_1[7]:code_num_1[6];

		code_idx[0]<=(code_num_1[0]>=code_num_1[1])?1:0;
		code_idx[1]<=(code_num_1[2]>=code_num_1[3])?3:2;
		code_idx[2]<=(code_num_1[4]>=code_num_1[5])?5:4;
		code_idx[3]<=(code_num_1[6]>=code_num_1[7])?7:6;
	 end
	 
    else if(pipe6)//第六级流水 
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_num_tmp[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_num_tmp[3]:code_num_tmp[2];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];
		code_idx[1]<=(code_num_tmp[2]>=code_num_tmp[3])?code_idx[3]:code_idx[2];////5.86
     end 
  
    else if(pipe7)//第七级流水
     begin
		code_num_tmp[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_num_tmp[1]:code_num_tmp[0];
		code_idx[0]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0];  
		code_num_tmp[1]<=(code_num_1[8]>=code_num_1[9])?code_num_1[9]:code_num_1[8];
		code_idx[1]<=(code_num_1[8]>=code_num_1[9])?9:8; 
     end 
  
    else if(pipe8)//第八级流水
     code_idx[5]<=(code_num_tmp[0]>=code_num_tmp[1])?code_idx[1]:code_idx[0]; 
    
  end
  
  assign id0=code_idx[4];//输出频率最小值  
  assign id1=code_idx[5];//输出频率次小值
  
endmodule

module HuffmanCoding(clk,rst_n,start,data_in,output_start,output_data,output_done);
  input rst_n;
  input clk;
  input start;
  input [3:0]data_in;
  output output_data;
  output output_done;
  output output_start;
 
      
   wire start_keep; 
   wire coding_sign;

     
   wire [7:0]code_r0;
   wire [7:0]code_r1;
   wire [7:0]code_r2;
   wire [7:0]code_r3;
   wire [7:0]code_r4;
   wire [7:0]code_r5;
   wire [7:0]code_r6;
   wire [7:0]code_r7;
   wire [7:0]code_r8;
   wire [7:0]code_r9;
   
   wire [3:0]id0;
   wire [3:0]id1;
   
   wire [9:0]tree0_tmp;
   wire [9:0]tree1_tmp;
   
   wire  [6:0]codehf_0;
   wire  [6:0]codehf_1;
   wire  [6:0]codehf_2;
   wire  [6:0]codehf_3;
   wire  [6:0]codehf_4;
   wire  [6:0]codehf_5;
   wire  [6:0]codehf_6;
   wire  [6:0]codehf_7;
   wire  [6:0]codehf_8;
   wire  [6:0]codehf_9;
   
   wire  [2:0]code_length_0;
   wire  [2:0]code_length_1;
   wire  [2:0]code_length_2;
   wire  [2:0]code_length_3;
   wire  [2:0]code_length_4;
   wire  [2:0]code_length_5;
   wire  [2:0]code_length_6;
   wire  [2:0]code_length_7;
   wire  [2:0]code_length_8;
   wire  [2:0]code_length_9; 
     
   wire fifo_rd; 
   wire fsm_start;
   wire [3:0]data_in_out;

 control control(.clk(clk),.rst_n(rst_n),.start(start),.start_keep(start_keep),.coding_sign(coding_sign),.fsm_start(fsm_start),.pipe1(coding_sign_delay),.pipe2(coding_sign_delay2),.pipe3(coding_sign_delay3),.pipe4(coding_sign_delay4),.pipe5(coding_sign_delay5),.pipe6(coding_sign_delay6),.pipe7(coding_sign_delay7),.pipe8(coding_sign_delay8),.refresh(coding_sign_delay9),.coding_encoder(coding_sign_tree));
 codenum codenum(.clk(clk),.rst_n(rst_n),.en_1(start_keep),.en_2(coding_sign_delay9),.data_in(data_in),.code_0(code_r0),.code_1(code_r1),.code_2(code_r2),.code_3(code_r3),.code_4(code_r4),.code_5(code_r5),.code_6(code_r6),.code_7(code_r7),.code_8(code_r8),.code_9(code_r9),.id0_r(id0),.id1_r(id1));
 selector selector(.clk(clk),.rst_n(rst_n),.coding_sign(coding_sign),.pipe1(coding_sign_delay),.pipe2(coding_sign_delay2),.pipe3(coding_sign_delay3),.pipe4(coding_sign_delay4),.pipe5(coding_sign_delay5),.pipe6(coding_sign_delay6),.pipe7(coding_sign_delay7),.pipe8(coding_sign_delay8),.code_r0(code_r0),.code_r1(code_r1),.code_r2(code_r2),.code_r3(code_r3),.code_r4(code_r4),.code_r5(code_r5),.code_r6(code_r6),.code_r7(code_r7),.code_r8(code_r8),.code_r9(code_r9),.id0(id0),.id1(id1));
 codetree codetree(.clk(clk),.rst_n(rst_n),.en(coding_sign_delay9),.vic0(id0),.vic1(id1),.tree0_tmp(tree0_tmp),.tree1_tmp(tree1_tmp));
 encoder encoder(.clk(clk),.rst_n(rst_n),.en(coding_sign_tree),.r_tree(coding_sign_delay9),.tree_r0(tree0_tmp),.tree_r1(tree1_tmp),.codehf_0(codehf_0),.codehf_1(codehf_1),.codehf_2(codehf_2),.codehf_3(codehf_3),.codehf_4(codehf_4),.codehf_5(codehf_5),.codehf_6(codehf_6),.codehf_7(codehf_7),.codehf_8(codehf_8),.codehf_9(codehf_9),.
 code_length_0(code_length_0),.code_length_1(code_length_1),.code_length_2(code_length_2),.code_length_3(code_length_3),.code_length_4(code_length_4),.code_length_5(code_length_5),.code_length_6(code_length_6),.code_length_7(code_length_7),.code_length_8(code_length_8),.code_length_9(code_length_9));
 Output Output(.clk(clk),.rst_n(rst_n),
 .codehf_r0(codehf_0),.codehf_r1(codehf_1),.codehf_r2(codehf_2),.codehf_r3(codehf_3),.codehf_r4(codehf_4),.codehf_r5(codehf_5),.codehf_r6(codehf_6),.codehf_r7(codehf_7),.codehf_r8(codehf_8),.codehf_r9(codehf_9),
 .length_r0(code_length_0),.length_r1(code_length_1),.length_r2(code_length_2),.length_r3(code_length_3),.length_r4(code_length_4),.length_r5(code_length_5),.length_r6(code_length_6),.length_r7(code_length_7),.length_r8(code_length_8),.length_r9(code_length_9),
 .output_data(output_data),.data_in(data_in_out),.output_start(output_start),.output_done(output_done),.fifo_rd(fifo_rd),.fsm_start(fsm_start));
 data_fifo data_fifo(.clk(clk),.rst(rst_n),.wr_data(data_in),.rd_data(data_in_out),.rd_en(fifo_rd),.wr_en(start_keep));
 
 endmodule
